"""
testpoint_app/testpoint/__init__.py  —  SSO version
====================================================
Only change from the original: imports and registers sso_bp so the
/sso/status debug endpoint is available.
"""

from flask import Flask
from flask_mail import Mail
from dotenv import load_dotenv
import os

load_dotenv()
passwordDB    = os.getenv("DBPASSWORD")
emailpassword = os.getenv("GMAILPASS")
email         = os.getenv("GMAIL")

db_config = {
    "host":        "localhost",
    "user":        "root",
    "password":    passwordDB,
    "database":    "db_exam",
    "auth_plugin": "mysql_native_password",
}

mail = Mail()


def create_app():
    app = Flask(__name__)
    app.secret_key = "Secret@123_key"

    app.config["MAIL_SERVER"]   = "smtp.gmail.com"
    app.config["MAIL_PORT"]     = 465
    app.config["MAIL_USERNAME"] = email
    app.config["MAIL_PASSWORD"] = emailpassword
    app.config["MAIL_USE_TLS"]  = False
    app.config["MAIL_USE_SSL"]  = True

    mail.init_app(app)

    # ── Blueprints ─────────────────────────────────────────────────────────────
    from testpoint.Auth.login    import auth
    from testpoint.Admin.admin   import admin
    from testpoint.Student.student import student
    from testpoint.Teacher.teacher import teacher
    from testpoint.api           import api
    from testpoint.sso           import sso_bp, sync_session_from_cookie   # ← NEW

    # Keep the Flask session in sync with the Portal's auth_token cookie
    # on every request to these blueprints, so existing *_logged_in()
    # checks throughout Admin/Teacher/Student routes work without each
    # route needing to call require_sso() individually.
    # MUST be set up before the blueprints are registered.            ← NEW
    admin.before_request(sync_session_from_cookie)
    teacher.before_request(sync_session_from_cookie)
    student.before_request(sync_session_from_cookie)

    app.register_blueprint(auth)
    app.register_blueprint(admin,   url_prefix="/admin")
    app.register_blueprint(teacher, url_prefix="/teacher")
    app.register_blueprint(student, url_prefix="/student")
    app.register_blueprint(api)
    app.register_blueprint(sso_bp)

    return app
