"""
loginPY.py — Auth blueprint for Attendeez (SSO version)

ALL login forms have been removed. Authentication is handled entirely
by the Portal (port 5000). This module only:
  1. Redirects any /login URL to the Portal.
  2. Handles /logout (clears local session + portal cookie).
  3. Provides a /sso/callback entry point that downstream routes use
     via the require_sso() helper in Main/sso.py.

Password reset and OTP flows have been removed; users manage their
credentials through the Portal.
"""

import os
from flask import Blueprint, redirect, url_for, session, request, make_response

PORTAL_URL = os.getenv('PORTAL_URL', 'http://127.0.0.1:5000')

auth = Blueprint('auth', __name__, template_folder='templates')


@auth.after_request
def add_header(response):
    response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
    response.headers['Pragma'] = 'no-cache'
    return response


# ── All /login variants → Portal ───────────────────────────────────────────────

@auth.route('/login')
@auth.route('/student/login')
@auth.route('/teacher/login')
@auth.route('/admin/login')
def login_redirect():
    """Any attempt to hit a local login page sends the user to the Portal."""
    return redirect(PORTAL_URL)


# ── Logout ─────────────────────────────────────────────────────────────────────

@auth.route('/logout')
def logout():
    """
    Clear the local Flask session and the shared auth_token cookie,
    then redirect to the Portal (which will show the login page).
    """
    session.clear()
    resp = make_response(redirect(PORTAL_URL))
    # Expire the shared SSO cookie
    resp.set_cookie('auth_token', '', expires=0, httponly=True, samesite='Lax')
    return resp


# ── Catch-all for removed auth pages ──────────────────────────────────────────

@auth.route('/forgot-password')
@auth.route('/reset-password')
@auth.route('/verify-otp')
@auth.route('/resend-otp')
@auth.route('/change-password')
def removed_auth_page():
    """These flows now live in the Portal. Redirect there."""
    return redirect(PORTAL_URL)
