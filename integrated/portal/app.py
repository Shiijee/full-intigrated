"""
portal/app.py  —  Edukado Central Portal  (port 5000)
The single login gate for all modules.

NEW in this version
───────────────────
  POST /api/verify-token   ← modules call this to validate an auth_token cookie
  GET  /api/ping           ← health-check used by the hub
"""

import jwt
import datetime
from flask import Flask, render_template, request, redirect, make_response, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from db_config import get_db_connection

app = Flask(__name__)
app.secret_key = "super_secret_key_edukado_portal_2024"   # must match PORTAL_SECRET in every module's .env


# ── Helpers ───────────────────────────────────────────────────────────────────

def create_token(user_id, username, full_name, role="student"):
    payload = {
        "user_id":   user_id,
        "username":  username,
        "full_name": full_name,
        "role":      role,
        "exp":       datetime.datetime.utcnow() + datetime.timedelta(hours=8),
    }
    return jwt.encode(payload, app.secret_key, algorithm="HS256")


def decode_token(token):
    """Return payload dict or None."""
    try:
        return jwt.decode(token, app.secret_key, algorithms=["HS256"])
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None


# ── Pages ─────────────────────────────────────────────────────────────────────

@app.route("/")
def index():
    token = request.cookies.get("auth_token")
    next_url = request.args.get("next", "")
    if token:
        user_data = decode_token(token)
        if user_data:
            if next_url:
                return redirect(next_url)
            return render_template("index.html", user=user_data)
    return render_template("login.html", next=next_url)


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "GET":
        return render_template("login.html", next=request.args.get("next", ""))

    username = request.form.get("username", "").strip()
    password = request.form.get("password", "").strip()
    next_url  = request.args.get("next") or request.form.get("next") or "/"

    conn   = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(
        "SELECT id, username, password, full_name, role FROM users "
        "WHERE username = %s",
        (username,),
    )
    user = cursor.fetchone()
    cursor.close()
    conn.close()

    if user and check_password_hash(user["password"], password):
        token = create_token(user["id"], user["username"], user["full_name"], user.get("role", "student"))
        resp  = make_response(redirect(next_url))
        # SameSite=Lax so the cookie is sent when the browser follows the
        # redirect back from a module's /login page.
        resp.set_cookie(
            "auth_token", token,
            httponly=True, samesite="Lax",
            max_age=8 * 3600,
        )
        return resp

    return render_template("login.html", error="Invalid username or password.")


@app.route("/logout")
def logout():
    resp = make_response(redirect("/"))
    resp.set_cookie("auth_token", "", expires=0, samesite="Lax")
    return resp


# ── SSO API ───────────────────────────────────────────────────────────────────

@app.route("/api/ping")
def ping():
    """Health-check consumed by the Integration Hub."""
    return jsonify({"system": "Portal", "status": "ok"})


@app.route("/api/verify-token", methods=["POST"])
def verify_token():
    """
    Called by every module's sso.py to validate a cookie.

    Request body (JSON):
        { "token": "<jwt string>" }

    Success response (200):
        {
            "valid": true,
            "user": {
                "user_id":   <int>,
                "full_name": "<string>",
                "role":      "<string>"
            }
        }

    Failure response (401):
        { "valid": false, "reason": "<string>" }
    """
    body  = request.get_json(silent=True) or {}
    token = body.get("token")

    if not token:
        return jsonify({"valid": False, "reason": "No token provided"}), 401

    payload = decode_token(token)
    if payload is None:
        return jsonify({"valid": False, "reason": "Token invalid or expired"}), 401

    return jsonify({
        "valid": True,
        "user": {
            "user_id":   payload.get("user_id"),
            "username":  payload.get("username"),
            "full_name": payload.get("full_name"),
            "role":      payload.get("role", "student"),
        },
    })


@app.route("/api/create-user", methods=["POST"])
def create_user():
    """
    Called by a module right after it creates a user locally, so that
    person can immediately log in via the Portal across every module.

    Request body (JSON):
        {
            "username":    "<string>",   required
            "password":    "<string>",   required, PLAINTEXT
            "full_name":   "<string>",   required
            "role":        "<string>",   required - one of:
                                          superadmin | admin | teacher | student
            "email":       "<string>",   optional
            "external_id": "<string>"    optional - module's own ID for this person
        }

    Success response (201):
        { "success": true, "user_id": <int> }

    Failure response (400 or 409):
        { "success": false, "reason": "<string>" }
    """
    body = request.get_json(silent=True) or {}

    username    = (body.get("username") or "").strip()
    password    = body.get("password") or ""
    full_name   = (body.get("full_name") or "").strip()
    role        = (body.get("role") or "").strip()
    email       = body.get("email")
    external_id = body.get("external_id")

    valid_roles = ("superadmin", "admin", "teacher", "student")

    if not username or not password or not full_name:
        return jsonify({"success": False, "reason": "username, password, and full_name are required"}), 400

    if role not in valid_roles:
        return jsonify({"success": False, "reason": f"role must be one of {valid_roles}"}), 400

    conn   = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT id FROM users WHERE username = %s", (username,))
        if cursor.fetchone():
            return jsonify({"success": False, "reason": f"Username '{username}' already exists"}), 409

        cursor.execute(
            "INSERT INTO users (username, password, full_name, email, role, external_id) "
            "VALUES (%s, %s, %s, %s, %s, %s)",
            (username, generate_password_hash(password), full_name, email, role, external_id),
        )
        conn.commit()
        new_id = cursor.lastrowid
        return jsonify({"success": True, "user_id": new_id}), 201

    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "reason": str(e)}), 500

    finally:
        cursor.close()
        conn.close()


@app.route("/api/update-password", methods=["POST"])
def update_password():
    """
    Called by a module when a user changes their password locally,
    so the portal's central DB stays in sync.
    """
    body = request.get_json(silent=True) or {}
    username = body.get("username")
    current_password = body.get("current_password")
    new_password = body.get("new_password")

    if not username or not current_password or not new_password:
        return jsonify({"success": False, "reason": "username, current_password, and new_password are required"}), 400

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT password FROM users WHERE username = %s", (username,))
        user = cursor.fetchone()
        
        if not user:
            return jsonify({"success": False, "reason": "User not found"}), 404
            
        if not check_password_hash(user["password"], current_password):
            return jsonify({"success": False, "reason": "Incorrect current password"}), 401
            
        cursor.execute("UPDATE users SET password = %s WHERE username = %s", (generate_password_hash(new_password), username))
        conn.commit()
        return jsonify({"success": True}), 200
    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "reason": str(e)}), 500
    finally:
        cursor.close()
        conn.close()



# ── Entry point ───────────────────────────────────────────────────────────────

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)