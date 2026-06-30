"""
Main/__init__.py — Application factory for Attendeez (SSO version)

The index route now uses require_sso() instead of checking session directly.
The sso_bp is registered to expose /sso/status for debugging.
"""

import os
from flask import Flask, redirect, url_for, request
from datetime import timedelta


def reg_app():
    app = Flask(__name__)

    # SECRET_KEY must match the Portal's secret so JWT cookies decode correctly.
    # Set this in your .env: SECRET_KEY=super_secret_key
    app.secret_key = os.getenv('SECRET_KEY', 'super_secret_key')

    # SESSION SETTINGS
    app.config['SESSION_COOKIE_SECURE'] = False   # set True in production (HTTPS)
    app.config['SESSION_COOKIE_HTTPONLY'] = True
    app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
    app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(hours=2)
    app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16 MB

    from flask_wtf.csrf import CSRFProtect
    csrf = CSRFProtect()
    csrf.init_app(app)

    # ── Root route: validate SSO token, then route by role ───────────────────
    @app.route('/')
    def index():
        from Main.sso import require_sso
        result = require_sso()
        # require_sso returns a redirect Response when unauthenticated
        if hasattr(result, 'status_code'):
            return result
        user = result
        role = user.get('role', 'student')
        if role == 'admin':
            return redirect(url_for('admin.dashboard'))
        if role == 'teacher':
            return redirect(url_for('teacher.dashboard'))
        return redirect(url_for('user.dashboard'))

    @app.route('/.well-known/appspecific/com.chrome.devtools.json')
    def chrome_devtools():
        return "{}", 200, {'Content-Type': 'application/json'}

    # ── Register blueprints ───────────────────────────────────────────────────
    from Main.admin.crudPY import crud
    from Main.admin.adminPY import admin
    from Main.auth.loginPY import auth          # now just redirects to portal
    from Main.student.studentPY import user
    from Main.teacher.teacherPY import teacher
    from Main.api import nc_api
    from Main.sso import sso_bp                # SSO status/debug endpoint

    app.register_blueprint(admin,   url_prefix='/admin')
    app.register_blueprint(crud)
    app.register_blueprint(auth,    url_prefix='/')
    app.register_blueprint(user,    url_prefix='/user')
    app.register_blueprint(teacher, url_prefix='/teacher')
    app.register_blueprint(nc_api)              # Integration API
    app.register_blueprint(sso_bp)              # SSO helpers

    # nc_api is a server-to-server JSON API (called by Voxify/TestPoint),
    # not a browser form — it has no CSRF token to send, so exempt it.
    csrf.exempt(nc_api)

    return app