"""
sso.py — SSO middleware for Attendeez (port 5001)
Replaces all local login logic. Every protected route calls
`require_sso()` which validates the auth_token cookie against the Portal.

Usage in a blueprint route:
    from Main.sso import require_sso, sso_bp

    @some_blueprint.route('/dashboard')
    def dashboard():
        user = require_sso()     # redirects to portal if not valid
        ...
"""

import os
import requests
from functools import wraps
from flask import Blueprint, request, redirect, session, jsonify, current_app

# ── Configuration ──────────────────────────────────────────────────────────────
PORTAL_URL = os.getenv('PORTAL_URL', 'http://127.0.0.1:5000')
VERIFY_ENDPOINT = f"{PORTAL_URL}/api/verify-token"

sso_bp = Blueprint('sso', __name__)


def _verify_token(token: str) -> dict | None:
    """
    Call the Portal's /api/verify-token endpoint.
    Returns the user dict on success, None on failure.
    """
    try:
        resp = requests.post(
            VERIFY_ENDPOINT,
            json={"token": token},
            timeout=3
        )
        if resp.status_code == 200:
            data = resp.json()
            if data.get("valid"):
                return data["user"]
    except requests.exceptions.RequestException as e:
        print(f"[SSO] Portal unreachable: {e}")
    return None


def require_sso():
    """
    Call this at the top of any protected route.
    - If valid: populates Flask session and returns user dict.
    - If invalid/missing: redirects browser to Portal login.

    Example:
        @admin_bp.route('/dashboard')
        def dashboard():
            user = require_sso()
            return render_template('dashboard.html', user=user)
    """
    token = request.cookies.get('auth_token')
    if token:
        user = _verify_token(token)
        if user:
            # Use username as session['user_id'] — Attendance's tables
            # (teachers.user_id, students.user_id, admins.username) all
            # use the Portal username as the local identifier, not the
            # Portal's numeric id. Storing the numeric id here caused
            # profile queries to return None (no matching row found).
            local_user_id = user.get('username') or user['user_id']
            session['user_id']   = local_user_id
            session['full_name'] = user['full_name']
            session['role']      = user['role']
            return user

    # No valid token → send them to the portal to log in
    return redirect(f"{PORTAL_URL}?next={request.url}")


def sso_required(f):
    """
    Decorator alternative to require_sso().
    Injects `current_user` kwarg into the route function.

    Example:
        @admin_bp.route('/dashboard')
        @sso_required
        def dashboard(current_user):
            return render_template('dashboard.html', user=current_user)
    """
    @wraps(f)
    def decorated(*args, **kwargs):
        result = require_sso()
        # require_sso returns a redirect Response if auth fails
        if hasattr(result, 'status_code'):
            return result
        return f(*args, current_user=result, **kwargs)
    return decorated


# ── SSO status endpoint (for debugging / health checks) ───────────────────────
@sso_bp.route('/sso/status')
def sso_status():
    token = request.cookies.get('auth_token')
    if not token:
        return jsonify({"authenticated": False, "reason": "No token cookie"}), 401
    user = _verify_token(token)
    if user:
        return jsonify({"authenticated": True, "user": user}), 200
    return jsonify({"authenticated": False, "reason": "Token rejected by portal"}), 401