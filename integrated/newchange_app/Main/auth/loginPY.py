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
from flask import Blueprint, redirect, url_for, session, request, make_response, render_template, flash
from werkzeug.security import generate_password_hash, check_password_hash
from Main.db import get_db_connection, get_cursor
import requests

PORTAL_URL = os.getenv('PORTAL_URL', 'http://127.0.0.1:5000')

auth = Blueprint('auth', __name__, template_folder='templates')


@auth.after_request
def add_header(response):
    response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
    response.headers['Pragma'] = 'no-cache'
    return response


# ── All /login variants → Portal ───────────────────────────────────────────────

@auth.route('/login', endpoint='login')
@auth.route('/student/login', endpoint='student_login')
@auth.route('/teacher/login', endpoint='teacher_login')
@auth.route('/admin/login', endpoint='admin_login')
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
def removed_auth_page():
    """These flows now live in the Portal. Redirect there."""
    return redirect(PORTAL_URL)


@auth.route('/change-password', methods=['GET', 'POST'], endpoint='change_password')
def change_password():
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))

    if request.method == 'POST':
        current_password = request.form.get('current_password')
        new_password     = request.form.get('new_password')
        confirm_password = request.form.get('confirm_password')

        if new_password != confirm_password:
            flash('Passwords do not match.', 'error')
            return render_template('change_password.html')

        role = session.get('role')
        uID  = session.get('user_id')  # This holds the username

        conn   = get_db_connection()
        cursor = get_cursor(conn)

        if role == 'student':
            table  = 'Students'
            id_col = 'user_id'
        elif role == 'teacher':
            table  = 'Teachers'
            id_col = 'user_id'
        else:
            table  = 'Admins'
            id_col = 'username'

        # Verify and Update via Portal
        try:
            resp = requests.post(f"{PORTAL_URL}/api/update-password", json={
                "username": str(uID),
                "current_password": current_password,
                "new_password": new_password
            }, timeout=5)
            
            data = resp.json()
            if data.get("success"):
                # Also update local DB to keep it in sync
                new_hash = generate_password_hash(new_password)
                cursor.execute(f"UPDATE {table} SET password_hash = %s WHERE {id_col} = %s", (new_hash, uID))
                conn.commit()
                flash('Password updated successfully.', 'success')
                dest = 'user.dashboard' if role == 'student' else 'teacher.dashboard' if role == 'teacher' else 'admin.dashboard'
                cursor.close()
                conn.close()
                return redirect(url_for(dest))
            else:
                if data.get("reason") == "Incorrect current password":
                    flash('Incorrect current password.', 'error')
                else:
                    flash(f'Error updating password: {data.get("reason", "Unknown error")}', 'error')
        except Exception as e:
            print("Error syncing with portal:", e)
            flash('Error communicating with authentication server.', 'error')

        cursor.close()
        conn.close()

    return render_template('change_password.html')