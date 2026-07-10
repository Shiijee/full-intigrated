from flask import Flask, redirect, url_for, session
import os
from datetime import timedelta


def reg_app():
    app = Flask(__name__)

    app.secret_key = os.getenv('SECRET_KEY', os.urandom(32))

    # SESSION SETTINGS
    app.config['SESSION_COOKIE_SECURE'] = False  # 🔥 IMPORTANT (local dev)
    app.config['SESSION_COOKIE_HTTPONLY'] = True
    app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
    app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(hours=6)
    app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max upload

    from flask_wtf.csrf import CSRFProtect
    csrf = CSRFProtect()
    csrf.init_app(app)

    @app.route('/')
    def index():
        if 'user_id' in session:
            role = session.get('role')
            if role == 'student': return redirect(url_for('user.dashboard'))
            if role == 'teacher': return redirect(url_for('teacher.dashboard'))
            if role == 'admin': return redirect(url_for('admin.dashboard'))

        # Local Flask session is empty, but the browser may still carry a
        # valid Portal auth_token cookie (e.g. arriving fresh from the
        # Portal hub). Verify it before bouncing back out.
        from Main.sso import require_sso
        result = require_sso()
        if hasattr(result, 'status_code'):
            # require_sso() already redirects to the Portal with ?next=
            # set to this URL, so the Portal can bounce the user straight
            # back here once they're authenticated.
            return result

        role = result.get('role')
        if role == 'student': return redirect(url_for('user.dashboard'))
        if role == 'teacher': return redirect(url_for('teacher.dashboard'))
        if role == 'admin': return redirect(url_for('admin.dashboard'))
        return redirect(PORTAL_URL)

    @app.route('/.well-known/appspecific/com.chrome.devtools.json')
    def chrome_devtools():
        return "{}", 200, {'Content-Type': 'application/json'}

    # IMPORT BLUEPRINTS
    from Main.admin.crudPY import crud
    from Main.admin.adminPY import admin
    from Main.auth.loginPY import auth, PORTAL_URL
    from Main.student.studentPY import user
    from Main.teacher.teacherPY import teacher
    from Main.api import nc_api

    app.register_blueprint(admin, url_prefix='/admin')
    app.register_blueprint(crud)
    app.register_blueprint(auth, url_prefix='/')
    app.register_blueprint(user, url_prefix='/user')
    app.register_blueprint(teacher, url_prefix='/teacher')
    app.register_blueprint(nc_api)  # already has url_prefix='/api' set on the Blueprint itself

    # This is a server-to-server API called by Voxify/TestPoint with a JSON
    # body, not a browser form — it can't carry a CSRF token, so it must be
    # exempted or every call gets rejected before reaching provision_user().
    csrf.exempt(nc_api)

    return app