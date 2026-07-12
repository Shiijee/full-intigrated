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


def _log_system_event(user_id, action, details=""):
    """Best-effort insert into system_logs. Never lets a logging failure
    break the request that triggered it."""
    if not user_id:
        return
    try:
        conn = current_app.config["get_db_connection"]()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO system_logs (user_id, action, details) VALUES (%s, %s, %s)",
            (user_id, action, details)
        )
        conn.commit()
        cursor.close()
        conn.close()
    except Exception:
        pass


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

        is_new_session = session.get("user_id") != user["user_id"] or not session.get("_login_logged")

        session["user_id"]   = user["user_id"]
        session["full_name"] = user["full_name"]
        session["role"]      = mapped_role

        # Log exactly once per browser session — _get_sso_user() runs on
        # every request, so without this guard every page view would
        # insert a new "login" row.
        if is_new_session:
            session["_login_logged"] = True
            _log_system_event(user["user_id"], "login", f"{mapped_role} logged in")
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
        f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>No College Assigned — Voxify</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;0,900;1,700&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
<style>
  :root {{
    --ink:       #0d1117;
    --paper:     #f5f0e8;
    --navy:      #1a3a5c;
    --navy-dark: #122840;
    --navy-mid:  #1e4470;
    --gold:      #d4a843;
    --gold-dim:  rgba(212,168,67,0.15);
    --accent:    #c8392b;
    --muted:     #8a8070;
    --border:    #ddd5c4;
  }}
  * {{ box-sizing: border-box; margin: 0; padding: 0; }}
  body {{
    font-family: 'DM Sans', sans-serif;
    background: var(--paper);
    color: var(--ink);
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 24px;
    background-image:
      radial-gradient(circle at 15% 20%, rgba(26,58,92,0.06) 0%, transparent 45%),
      radial-gradient(circle at 85% 80%, rgba(212,168,67,0.10) 0%, transparent 45%);
  }}
  .card {{
    width: 100%;
    max-width: 480px;
    background: #fff;
    border: 1px solid var(--border);
    border-radius: 14px;
    box-shadow: 0 16px 48px rgba(13,17,23,0.14);
    overflow: hidden;
  }}
  .card-top {{
    background: linear-gradient(135deg, var(--navy) 0%, var(--navy-mid) 100%);
    padding: 30px 32px 26px;
    position: relative;
  }}
  .card-top::after {{
    content: '';
    position: absolute;
    left: 0; right: 0; bottom: 0;
    height: 4px;
    background: linear-gradient(90deg, var(--accent), var(--gold), var(--navy));
  }}
  .badge {{
    width: 52px; height: 52px;
    border-radius: 12px;
    background: var(--gold-dim);
    border: 1px solid rgba(212,168,67,0.35);
    display: flex; align-items: center; justify-content: center;
    margin-bottom: 16px;
  }}
  .badge svg {{ width: 26px; height: 26px; stroke: var(--gold); }}
  .card-top h1 {{
    font-family: 'Playfair Display', serif;
    font-weight: 700;
    font-size: 1.5rem;
    color: #fff;
    line-height: 1.2;
  }}
  .card-top p {{
    color: rgba(255,255,255,0.72);
    font-size: 0.85rem;
    margin-top: 6px;
    font-weight: 300;
  }}
  .card-body {{
    padding: 28px 32px 32px;
  }}
  .card-body p {{
    font-size: 0.92rem;
    line-height: 1.65;
    color: var(--ink);
    margin-bottom: 14px;
  }}
  .card-body p:last-of-type {{ margin-bottom: 0; }}
  .card-body b {{ color: var(--navy); font-weight: 600; }}
  .steps {{
    background: var(--paper);
    border: 1px solid var(--border);
    border-radius: 10px;
    padding: 16px 18px;
    margin: 18px 0;
    display: flex;
    gap: 12px;
    align-items: flex-start;
  }}
  .steps svg {{ width: 18px; height: 18px; stroke: var(--accent); flex-shrink: 0; margin-top: 2px; }}
  .steps p {{ margin: 0; font-size: 0.87rem; color: var(--muted); }}
  .steps b {{ color: var(--ink); }}
  .btn {{
    display: inline-flex;
    align-items: center;
    gap: 8px;
    margin-top: 22px;
    background: var(--navy);
    color: #fff !important;
    text-decoration: none;
    font-size: 0.87rem;
    font-weight: 600;
    padding: 11px 22px;
    border-radius: 8px;
    transition: background 0.18s ease;
  }}
  .btn:hover {{ background: var(--navy-dark); }}
  .btn svg {{ width: 15px; height: 15px; stroke: #fff; }}
</style>
</head>
<body>
  <div class="card">
    <div class="card-top">
      <div class="badge">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M22 10v6M2 10l10-5 10 5-10 5-10-5zM6 12v5c0 1.5 3 3 6 3s6-1.5 6-3v-5"/>
        </svg>
      </div>
      <h1>No College Assigned Yet</h1>
      <p>Voxify · Admin Access</p>
    </div>
    <div class="card-body">
      <p>Hi <b>{user.get('full_name', 'there')}</b> — your admin account isn't linked to a college yet, so there's no election data to show.</p>
      <div class="steps">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
        </svg>
        <p>Ask your superadmin to open <b>Manage Admins</b> and assign you to a college. Once that's done, refresh this page.</p>
      </div>
      <a class="btn" href="{PORTAL_URL}">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/>
        </svg>
        Back to Portal
      </a>
    </div>
  </div>
</body>
</html>""",
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
    _log_system_event(session.get("user_id"), "logout", f"{session.get('role', 'user')} logged out")
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