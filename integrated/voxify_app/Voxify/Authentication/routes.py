"""
voxify_app/Voxify/Authentication/routes.py  —  SSO version
===========================================================
All local login forms, OTP flows, and password-reset logic are REMOVED.
Authentication is handled by the Portal (port 5000).

What remains (required by other blueprints):
  • login_required, admin_required, voter_required, superadmin_required decorators
    — now validated against the Portal via the auth_token cookie instead of a
      local DB password check.
  • /voter-login and /admin-login routes  → redirect to Portal
  • /logout                               → clears session + cookie → Portal
  • /check-session                        → JSON health-check (unchanged)
  • /sso/status                           → debug endpoint
"""

import os
import requests
from functools import wraps
from flask import (
    Blueprint, redirect, url_for, session,
    request, jsonify, make_response, current_app
)

auth_bp = Blueprint(
    "auth", __name__,
    template_folder="templates",
    static_folder="static",
    static_url_path="/auth/static",
)

PORTAL_URL      = os.getenv("PORTAL_URL", "http://127.0.0.1:5000")
VERIFY_ENDPOINT = f"{PORTAL_URL}/api/verify-token"


# ── SSO token helper ──────────────────────────────────────────────────────────

def _verify_token(token: str) -> dict | None:
    """Call the Portal's /api/verify-token. Returns user dict or None."""
    try:
        resp = requests.post(VERIFY_ENDPOINT, json={"token": token}, timeout=3)
        if resp.status_code == 200:
            data = resp.json()
            if data.get("valid"):
                return data["user"]
    except requests.exceptions.RequestException as e:
        print(f"[Voxify SSO] Portal unreachable: {e}")
    return None


def _map_role(portal_role: str) -> str:
    """
    Translate a Portal role into Voxify's own role vocabulary.

    Portal roles: superadmin | admin | teacher | student
    Voxify roles: superadmin | admin | voter

    Per the mirroring matrix:
      - superadmin → superadmin  (Voxify has superadmin)
      - admin      → admin       (Voxify has admin)
      - student    → voter       (students are voters in Voxify)
      - teacher    → None        (teachers have NO Voxify role — blocked)
    """
    mapping = {
        "superadmin": "superadmin",
        "admin":      "admin",
        "student":    "voter",
    }
    return mapping.get(portal_role)   # returns None for 'teacher'


def _resolve_local_user_id(username: str) -> int | None:
    """
    Look up Voxify's own db_voting.users.id by matching student_id
    against the Portal's username. The Portal and Voxify each have
    their own separate `users` table with independent auto-increment
    ids, so session['user_id'] must store Voxify's local id (not the
    Portal's) — existing code throughout Voxify (audit_logs FK,
    college lookups, etc.) all assume session['user_id'] is a valid
    db_voting.users.id.
    """
    if not username:
        return None
    conn = current_app.config["get_db_connection"]()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT id FROM users WHERE student_id = %s LIMIT 1", (username,))
        row = cursor.fetchone()
        return row["id"] if row else None
    finally:
        cursor.close()
        conn.close()


def _get_sso_user() -> dict | None:
    """
    Read the auth_token cookie, verify it with the Portal,
    populate the Flask session, and return the user dict
    (with role translated to Voxify's vocabulary, and user_id
    resolved to Voxify's own local users.id).
    Returns None if the token is missing or invalid.
    """
    token = request.cookies.get("auth_token")
    if not token:
        return None
    user = _verify_token(token)
    if user:
        mapped_role = _map_role(user.get("role", "student"))

        # None means this role has no Voxify equivalent (e.g. teacher)
        # Treat as unauthenticated so decorators redirect to Portal
        if mapped_role is None:
            return None

        local_id    = _resolve_local_user_id(user.get("username"))

        user = dict(user)            # don't mutate Portal's response in place
        user["role"] = mapped_role
        if local_id is not None:
            user["user_id"] = local_id   # overwrite Portal id with Voxify's local id

        session["user_id"]   = user["user_id"]
        session["full_name"] = user["full_name"]
        session["role"]      = mapped_role
    return user


# ── Auth decorators (imported by Admin, Voter, SuperAdmin blueprints) ─────────

def _access_denied(user, required_label):
    """
    Shared 403 response for an authenticated user whose role doesn't
    match what a route requires. Returning this directly (instead of
    redirecting to the Portal) prevents an infinite redirect loop:
    redirecting an already-logged-in-but-wrong-role user back to the
    Portal just sends them straight back here.
    """
    return (
        f"<h2>403 — Access Denied</h2>"
        f"<p>You're logged in as <b>{user.get('full_name', 'Unknown')}</b> "
        f"(role: <b>{user.get('role', 'unknown')}</b>), which doesn't have "
        f"permission to view this page. This page requires: <b>{required_label}</b>.</p>"
        f"<p><a href=\"/\">Go to your dashboard</a> · "
        f"<a href=\"{PORTAL_URL}\">Back to Portal</a></p>",
        403,
    )


def login_required(f):
    """Require any authenticated Portal user."""
    @wraps(f)
    def decorated(*args, **kwargs):
        user = _get_sso_user()
        if not user:
            return redirect(f"{PORTAL_URL}?next={request.url}")
        return f(*args, **kwargs)
    return decorated


def _get_college_id(user_id) -> int | None:
    """Look up this user's college_id directly (small, local helper —
    avoids importing from Admin.routes to prevent a circular import)."""
    conn = current_app.config["get_db_connection"]()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT college_id FROM users WHERE id=%s", (user_id,))
        row = cursor.fetchone()
        return row["college_id"] if row else None
    finally:
        cursor.close()
        conn.close()


def _no_college_assigned(user):
    """
    Shown to a regular 'admin' (not superadmin) whose college_id is NULL —
    typically a brand-new account mirrored in from TestPoint/Attendance,
    which has no concept of "college" and therefore can't supply one at
    provisioning time. Without this guard, such an admin would silently
    fall into the same code path as a superadmin and see system-wide data
    across every college, which is an access-control gap, not just a
    display bug.
    """
    return (
        f"<h2>No College Assigned Yet</h2>"
        f"<p>Hi <b>{user.get('full_name', 'there')}</b> — your admin account "
        f"isn't linked to a college yet, so there's no election data to show.</p>"
        f"<p>Ask your superadmin to open <b>Manage Admins</b> and assign you "
        f"to a college. Once that's done, refresh this page.</p>"
        f"<p><a href=\"{PORTAL_URL}\">Back to Portal</a></p>",
        403,
    )


def admin_required(f):
    """Require role == 'admin' or 'superadmin'.

    A plain 'admin' (not superadmin) additionally must have a college_id
    assigned. Superadmins are exempt — NULL college_id for them means
    "all colleges", which is correct. For a regular admin, NULL college_id
    almost always means they were auto-mirrored from another module (which
    has no college data to send) and haven't been assigned one yet in
    Voxify — letting them through would leak every college's data to them.
    """
    @wraps(f)
    def decorated(*args, **kwargs):
        user = _get_sso_user()
        if not user:
            return redirect(f"{PORTAL_URL}?next={request.url}")
        role = user.get("role")
        if role not in ("admin", "superadmin"):
            return _access_denied(user, "admin or superadmin")
        if role == "admin" and _get_college_id(user.get("user_id")) is None:
            return _no_college_assigned(user)
        return f(*args, **kwargs)
    return decorated


def voter_required(f):
    """Require role == 'voter'."""
    @wraps(f)
    def decorated(*args, **kwargs):
        user = _get_sso_user()
        if not user:
            return redirect(f"{PORTAL_URL}?next={request.url}")
        if user.get("role") != "voter":
            return _access_denied(user, "voter")
        return f(*args, **kwargs)
    return decorated


def superadmin_required(f):
    """Require role == 'superadmin'."""
    @wraps(f)
    def decorated(*args, **kwargs):
        user = _get_sso_user()
        if not user:
            return redirect(f"{PORTAL_URL}?next={request.url}")
        if user.get("role") != "superadmin":
            return _access_denied(user, "superadmin")
        return f(*args, **kwargs)
    return decorated


# ── Login routes → Portal ─────────────────────────────────────────────────────

@auth_bp.route("/voter-login", methods=["GET", "POST"])
def voter_login():
    return redirect(f"{PORTAL_URL}?next={request.host_url}voter/dashboard")


@auth_bp.route("/admin-login", methods=["GET", "POST"])
def admin_login():
    return redirect(f"{PORTAL_URL}?next={request.host_url}admin/dashboard")


# ── Logout ────────────────────────────────────────────────────────────────────

@auth_bp.route("/logout")
def logout():
    session.clear()
    resp = make_response(redirect(PORTAL_URL))
    resp.set_cookie("auth_token", "", expires=0, httponly=True, samesite="Lax")
    return resp


# ── Catch-alls for removed auth pages ────────────────────────────────────────

@auth_bp.route("/signup", methods=["GET", "POST"])
@auth_bp.route("/verify-otp", methods=["GET", "POST"])
@auth_bp.route("/resend-otp")
@auth_bp.route("/forgot-password", methods=["GET", "POST"])
@auth_bp.route("/verify-forgot-otp", methods=["GET", "POST"])
@auth_bp.route("/reset-password", methods=["GET", "POST"])
@auth_bp.route("/resend-forgot-otp")
def removed_auth_page():
    return redirect(PORTAL_URL)


# ── Utility / debug endpoints ─────────────────────────────────────────────────

@auth_bp.route("/check-session")
def check_session():
    user = _get_sso_user()
    if user:
        return jsonify({"authenticated": True, "user": user})
    return jsonify({"authenticated": False}), 401


@auth_bp.route("/sso/status")
def sso_status():
    token = request.cookies.get("auth_token")
    if not token:
        return jsonify({"authenticated": False, "reason": "No token cookie"}), 401
    user = _verify_token(token)
    if user:
        return jsonify({"authenticated": True, "user": user}), 200
    return jsonify({"authenticated": False, "reason": "Token rejected by portal"}), 401