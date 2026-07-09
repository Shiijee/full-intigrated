"""
testpoint_app/testpoint/Auth/login.py  —  SSO version
======================================================
All local login / register / OTP / reset forms are REMOVED.
Authentication is handled by the Portal (port 5000).

What remains:
  • redirect /login → Portal
  • /logout          clears session + auth_token cookie, back to Portal
  • catch-alls for old auth URLs so bookmarks don't 404
  • All non-auth routes (register, upload, etc.) untouched below
"""

import os
from flask import (
    Blueprint, redirect, url_for, session,
    request, make_response
)

PORTAL_URL = os.getenv("PORTAL_URL", "http://127.0.0.1:5000")

auth = Blueprint(
    "auth", __name__,
    template_folder="templates",
    static_folder="static",
    static_url_path="/auth/static",
)


# ── Logged-in checks ──────────────────────────────────────────────────────────
# These are imported throughout Admin/Teacher/Student blueprints.
# session['user_logged_in'], session['admin_logged_in'],
# session['teacher_logged_in'], and session['role'] are now populated by
# testpoint/sso.py's require_sso()/sso_required() after validating the
# Portal's auth_token cookie — not by a local password check.

def user_logged_in():
    return session.get('user_logged_in', False)


def admin_logged_in():
    return session.get('admin_logged_in', False) and session.get('role') in ['admin', 'super_admin']


def teacher_logged_in():
    return session.get('teacher_logged_in', False)


def pending_user_logged_in():
    """No local pending-registration flow anymore (Portal handles registration)."""
    return session.get('pending_user_logged_in', False)


# ── Cache-control ─────────────────────────────────────────────────────────────

@auth.after_request
def no_cache(response):
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"] = "no-cache"
    return response


# ── Login → Portal ────────────────────────────────────────────────────────────

@auth.route("/login", methods=["GET", "POST"])
@auth.route("/login/student", methods=["GET", "POST"])
@auth.route("/login/teacher", methods=["GET", "POST"])
@auth.route("/login/admin", methods=["GET", "POST"])
def login():
    """Any login attempt gets forwarded to the Portal."""
    next_url = request.url
    return redirect(f"{PORTAL_URL}?next={next_url}")


# ── Logout ────────────────────────────────────────────────────────────────────

@auth.route("/logout", methods=["GET", "POST"])
def logout():
    """
    Clear the local Flask session and the shared auth_token cookie,
    then send the user back to the Portal.
    """
    resp = make_response(redirect(PORTAL_URL))
    return resp


# ── Catch-alls for removed auth pages ────────────────────────────────────────

@auth.route("/register/student", methods=["GET", "POST"])
@auth.route("/register/teacher", methods=["GET", "POST"])
@auth.route("/verify_register", methods=["GET", "POST"])
@auth.route("/upload_verification", methods=["GET", "POST"])
@auth.route("/forgot-password", methods=["GET", "POST"])
@auth.route("/resend_otp", methods=["GET", "POST"])
@auth.route("/verify-reset-otp", methods=["GET", "POST"])
@auth.route("/reset-password", methods=["GET", "POST"])
def removed_page():
    """These flows now live in the Portal. Redirect there."""
    return redirect(PORTAL_URL)
