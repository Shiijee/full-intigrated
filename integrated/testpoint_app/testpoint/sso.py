"""
testpoint_app/testpoint/sso.py
==============================
SSO middleware for TestPoint (port 5000 in original, use your actual port).
Drop this file into testpoint_app/testpoint/ alongside __init__.py.

Usage in any blueprint route:
    from testpoint.sso import require_sso

    @student.route('/dashboard')
    def student_dashboard():
        user = require_sso()          # redirects to Portal if not valid
        ...

Or as a decorator:
    from testpoint.sso import sso_required

    @student.route('/dashboard')
    @sso_required
    def student_dashboard(current_user):
        ...
"""

import os
import requests
from functools import wraps
from flask import Blueprint, request, redirect, session, jsonify

# ── Config ────────────────────────────────────────────────────────────────────

PORTAL_URL       = os.getenv("PORTAL_URL", "http://127.0.0.1:5000")
VERIFY_ENDPOINT  = f"{PORTAL_URL}/api/verify-token"

sso_bp = Blueprint("sso", __name__)


# ── Internal helpers ──────────────────────────────────────────────────────────

def _verify_token(token: str) -> dict | None:
    """Call the Portal's /api/verify-token. Returns user dict or None."""
    try:
        resp = requests.post(VERIFY_ENDPOINT, json={"token": token}, timeout=3)
        if resp.status_code == 200:
            data = resp.json()
            if data.get("valid"):
                return data["user"]
    except requests.exceptions.RequestException as e:
        print(f"[SSO-TestPoint] Portal unreachable: {e}")
    return None


def _map_role(portal_role: str) -> str:
    """
    Translate a Portal role into TestPoint's own role vocabulary.

    Portal roles:    superadmin | admin | teacher | student
    TestPoint roles: super_admin | admin | teacher | student

    Only the superadmin spelling differs (underscore); everything
    else passes through unchanged.
    """
    if portal_role == "superadmin":
        return "super_admin"
    return portal_role


# ── Public helpers ────────────────────────────────────────────────────────────


def require_sso() -> dict:
    """
    Call at the top of any protected route.
    - Valid token and locally active → populates session, returns user dict.
    - Missing, bad, or locally archived  → redirects to Portal login.
    """
    token = request.cookies.get("auth_token")
    if token:
        user = _verify_token(token)
        if user:
            mapped_role = _map_role(user.get("role", "student"))
            user = dict(user)
            user["role"] = mapped_role
            local_user_id = user.get("username") or user["user_id"]
            user["user_id"] = local_user_id

            # --- Check local active status first ---
            import mysql.connector
            from testpoint import db_config

            conn = mysql.connector.connect(**db_config)
            is_active = False
            try:
                cursor = conn.cursor(dictionary=True)
                cursor.execute(
                    "SELECT is_active FROM users WHERE user_id = %s", (local_user_id,)
                )
                row = cursor.fetchone()
                if row:
                    is_active = row["is_active"] == 1
            except Exception as e:
                print(f"[SSO-TestPoint] Database check failed: {e}")
                is_active = True  # Graceful fallback on exception
            finally:
                if "cursor" in locals():
                    cursor.close()
                conn.close()

            if not is_active:
                session.clear()
                return redirect(f"{PORTAL_URL}?next={request.url}")

            # Keep legacy session keys so existing route logic still works
            session["user_logged_in"] = True
            session["admin_logged_in"] = mapped_role in ("admin", "super_admin")
            session["teacher_logged_in"] = mapped_role == "teacher"
            session["user_id"] = local_user_id
            session["full_name"] = user["full_name"]
            session["role"] = mapped_role
            return user

    return redirect(f"{PORTAL_URL}?next={request.url}")


def sso_required(f):
    """
    Decorator version of require_sso().
    Injects `current_user` keyword argument into the route function.
    """
    @wraps(f)
    def decorated(*args, **kwargs):
        result = require_sso()
        if hasattr(result, "status_code"):   # it's a redirect Response
            return result
        return f(*args, current_user=result, **kwargs)
    return decorated


def sync_session_from_cookie():
    """
    If a valid Portal auth_token cookie is present and user is locally active,
    populate the Flask session silently (no redirect, no error if missing/invalid/archived).
    """
    token = request.cookies.get("auth_token")
    if not token:
        return
    user = _verify_token(token)
    if not user:
        return

    mapped_role = _map_role(user.get("role", "student"))
    local_user_id = user.get("username") or user.get("user_id")

    # --- Check local active status first ---
    import mysql.connector
    from testpoint import db_config

    conn = mysql.connector.connect(**db_config)
    is_active = False
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT is_active FROM users WHERE user_id = %s", (local_user_id,)
        )
        row = cursor.fetchone()
        if row:
            is_active = row["is_active"] == 1
    except Exception as e:
        print(f"[SSO-TestPoint] Database check failed: {e}")
        is_active = True
    finally:
        if "cursor" in locals():
            cursor.close()
        conn.close()

    if not is_active:
        session.clear()
        return

    session["user_logged_in"] = True
    session["admin_logged_in"] = mapped_role in ("admin", "super_admin")
    session["teacher_logged_in"] = mapped_role == "teacher"
    session["user_id"] = local_user_id
    session["full_name"] = user.get("full_name")
    session["role"] = mapped_role


# ── Debug endpoint ────────────────────────────────────────────────────────────

@sso_bp.route("/sso/status")
def sso_status():
    token = request.cookies.get("auth_token")
    if not token:
        return jsonify({"authenticated": False, "reason": "No token cookie"}), 401
    user = _verify_token(token)
    if user:
        return jsonify({"authenticated": True, "user": user}), 200
    return jsonify({"authenticated": False, "reason": "Token rejected by portal"}), 401
