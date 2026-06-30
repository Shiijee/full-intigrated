from flask import Flask, redirect, url_for, request, session
from testpoint.__init__ import create_app
from testpoint.sso import sync_session_from_cookie
import os

app = create_app()

PORTAL_URL = os.getenv("PORTAL_URL", "http://127.0.0.1:5000")


def session_has_valid_role():
    return bool(session.get('user_logged_in') or session.get('admin_logged_in')
                or session.get('teacher_logged_in'))


@app.route('/')
def home():
    """
    Check the Portal's auth_token cookie directly and route by role,
    instead of always bouncing through auth.login — that always sent
    everyone (even already-logged-in users) back to the Portal with a
    next= pointing at a /login/* path, which isn't a real destination
    and caused a redirect loop.
    """
    sync_session_from_cookie()

    if session_has_valid_role():
        role = session.get('role')
        if role in ('admin', 'super_admin'):
            return redirect(url_for('admin.admin_dashboard'))
        elif role == 'teacher':
            return redirect(url_for('teacher.teacher_dashboard'))
        elif role == 'student':
            return redirect(url_for('student.student_dashboard'))

    return redirect(f"{PORTAL_URL}?next={request.host_url}")


@app.after_request
def add_no_cache_headers(response):
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
    return response


if __name__ == '__main__':
    app.run(debug=True, port=5003)