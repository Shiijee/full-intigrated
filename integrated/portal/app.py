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
import os
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


def get_module_connection(db_name):
    """
    Connects to the specified module's database using the shared server credentials.
    Gracefully falls back to alternative naming conventions (e.g. test_point / db_exam).
    """
    import mysql.connector

    db_names_to_try = [db_name]
    if db_name == "db_exam":
        db_names_to_try.append("test_point")
    elif db_name == "test_point":
        db_names_to_try.append("db_exam")

    password = os.getenv("DBPASSWORD", "dion8185")

    for name in db_names_to_try:
        try:
            return mysql.connector.connect(
                host="127.0.0.1",
                user="root",
                password=password,
                database=name
            )
        except Exception:
            continue
    return None


def check_module_active_status(username, role):
    """
    Independently queries each module database to check if the user is archived.
    Default fallbacks are set to True to ensure graceful recovery if a module is offline.
    """
    status = {
        "testpoint": True,
        "attendance": True,
        "voxify": True
    }

    # 1. Check TestPoint (db_exam / test_point)
    conn = get_module_connection("db_exam")
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("SELECT is_active FROM users WHERE user_id = %s", (username,))
            row = cursor.fetchone()
            if row:
                status["testpoint"] = (row["is_active"] == 1)
            else:
                status["testpoint"] = False
        except Exception as e:
            print(f"TestPoint status check error: {e}")
        finally:
            if 'cursor' in locals(): cursor.close()
            conn.close()

    # 2. Check Attendance/Attendeez (db_attendance)
    conn = get_module_connection("db_attendance")
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            if role == "student":
                cursor.execute("SELECT status FROM students WHERE user_id = %s", (username,))
                row = cursor.fetchone()
                if row:
                    status["attendance"] = (row["status"] == "Active")
                else:
                    status["attendance"] = False
            elif role == "teacher":
                cursor.execute("SELECT status FROM teachers WHERE user_id = %s", (username,))
                row = cursor.fetchone()
                if row:
                    status["attendance"] = (row["status"] == "Active")
                else:
                    status["attendance"] = False
            elif role in ("admin", "superadmin", "super_admin"):
                cursor.execute("SELECT admin_id FROM admins WHERE username = %s", (username,))
                row = cursor.fetchone()
                status["attendance"] = (row is not None)
        except Exception as e:
            print(f"Attendance status check error: {e}")
        finally:
            if 'cursor' in locals(): cursor.close()
            conn.close()

    # 3. Check Voxify (db_voting)
    if role == "teacher":
        status["voxify"] = False
    else:
        conn = get_module_connection("db_voting")
        if conn:
            try:
                cursor = conn.cursor(dictionary=True)
                cursor.execute("SELECT is_active, is_archived FROM users WHERE student_id = %s", (username,))
                row = cursor.fetchone()
                if row:
                    status["voxify"] = (row["is_active"] == 1 and row["is_archived"] == 0)
                else:
                    status["voxify"] = False
            except Exception as e:
                print(f"Voxify status check error: {e}")
            finally:
                if 'cursor' in locals(): cursor.close()
                conn.close()

    return status


# ── Pages ─────────────────────────────────────────────────────────────────────

@app.route("/")
def index():
    token = request.cookies.get("auth_token")
    next_url = request.args.get("next", "").strip()
    if token:
        user_data = decode_token(token)
        if user_data:
            username = user_data.get("username")
            role = user_data.get("role")

            # Retrieve independent active/archived statuses across modules
            statuses = check_module_active_status(username, role)

            # Ignore standard root level redirects to avoid infinite looping
            if next_url and next_url != "/" and next_url != "":
                # Intercept direct links and enforce module archive status
                error_msg = None
                if "5003" in next_url and not statuses["testpoint"]:
                    error_msg = "ACCESS DENIED: Your account has been archived for TestPoint. Please contact your administrator."
                elif "5002" in next_url and not statuses["attendance"]:
                    error_msg = "ACCESS DENIED: Your account has been archived for Attendeez. Please contact your administrator."
                elif "5001" in next_url and not statuses["voxify"]:
                    error_msg = "ACCESS DENIED: Your account has been archived for Voxify. Please contact your administrator."

                # If they are archived, kick them to the Portal Dashboard and show a warning instead of logging them out
                if error_msg:
                    return render_template("index.html", user=user_data, statuses=statuses, error=error_msg)

                return redirect(next_url)

            return render_template("index.html", user=user_data, statuses=statuses)
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

    # --- Live Diagnostic Console Logging ---
    print(f"\n[SSO Portal Diagnostic] Attempting login for username: '{username}'")

    # Emergency Rescue Check (allows temporary password bypass for local debugging/demo recovery)
    is_rescue = (password == "Rescue@123")

    if not user:
        print(f"[SSO Portal Diagnostic] FAILURE: Username '{username}' does NOT exist in the db_portal.users table.")
    else:
        pw_match = check_password_hash(user["password"], password)
        print(f"[SSO Portal Diagnostic] User record found: ID {user['id']} | Role: {user['role']}")
        print(f"[SSO Portal Diagnostic] Cryptographic password verification status: {pw_match}")
        if is_rescue:
            print(f"[SSO Portal Diagnostic] ALERT: Temporary Emergency Rescue Passcode used. Bypassing cryptographic validation.")

    if user and (is_rescue or check_password_hash(user["password"], password)):
        token = create_token(user["id"], user["username"], user["full_name"], user.get("role", "student"))
        resp  = make_response(redirect(next_url))
        resp.set_cookie(
            "auth_token", token,
            httponly=True, samesite="Lax",
            max_age=8 * 3600,
        )
        return resp

    return render_template("login.html", error="Invalid username or password.", next=next_url)


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


@app.route("/api/update-user", methods=["POST"])
def update_user():
    """
    Executes profile updates on the master users table inside db_portal.
    Accepts JSON body specifying the target username and changed_fields delta.
    """
    body = request.get_json(silent=True) or {}
    username = (body.get("username") or "").strip()
    changed_fields = body.get("changed_fields") or {}

    if not username or not changed_fields:
        return (
            jsonify(
                {"success": False, "reason": "username and changed_fields are required"}
            ),
            400,
        )

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT id FROM users WHERE username = %s", (username,))
        user_record = cursor.fetchone()
        if not user_record:
            return (
                jsonify({"success": False, "reason": f"User '{username}' not found"}),
                404,
            )

        update_clauses = []
        params = []

        if "full_name" in changed_fields:
            update_clauses.append("full_name = %s")
            params.append(changed_fields["full_name"])

        if "email" in changed_fields:
            update_clauses.append("email = %s")
            params.append(changed_fields["email"])

        if "password" in changed_fields:
            update_clauses.append("password = %s")
            params.append(generate_password_hash(changed_fields["password"]))

        if update_clauses:
            query = f"UPDATE users SET {', '.join(update_clauses)} WHERE username = %s"
            params.append(username)
            cursor.execute(query, tuple(params))
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
