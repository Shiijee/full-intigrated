"""
NewChange Integration API
Exposes enrollment, attendance, and student data.
Also consumes APIs from TestPoint and Voxify.
"""
from flask import Blueprint, jsonify, request
import requests
from Main.db import get_db_connection
from werkzeug.security import generate_password_hash

nc_api = Blueprint('nc_api', __name__, url_prefix='/api')

# URLs for partner systems — update with actual IPs on demo day
TESTPOINT_URL = "http://127.0.0.1:5000"
VOXIFY_URL    = "http://127.0.0.1:5001"


@nc_api.route('/ping')
def ping():
    return jsonify({"system": "NewChange", "status": "ok"})


@nc_api.route('/provision-user', methods=['POST'])
def provision_user():
    """
    Called by another module (Voxify, TestPoint) right after IT creates
    a user, so that same person gets a matching local profile row here
    too — letting them use Attendance with the same Portal identity.

    Request body (JSON):
        {
            "username":  "<string>",   required — used as uSID/uTID,
                                        or stored in admins.username
            "password":  "<string>",   required, PLAINTEXT
            "full_name": "<string>",   required — split on whitespace into
                                        first/middle/last as best-effort
            "role":      "<string>",   required — superadmin|admin|teacher|student
            "email":     "<string>",   optional
        }

    Success response (201):
        { "success": true }

    Failure response (400/409/500):
        { "success": false, "reason": "<string>" }
    """
    body = request.get_json(silent=True) or {}

    username  = (body.get("username") or "").strip()
    password  = body.get("password") or ""
    full_name = (body.get("full_name") or "").strip()
    role      = (body.get("role") or "").strip()
    email     = body.get("email") or f"{username}@placeholder.local"

    if not username or not password or not full_name:
        return jsonify({"success": False, "reason": "username, password, and full_name are required"}), 400

    if role not in ("superadmin", "admin", "teacher", "student"):
        return jsonify({"success": False, "reason": "role must be superadmin, admin, teacher, or student"}), 400

    # Best-effort name split: "First Middle Last" -> first/middle/last.
    # Two-word names get an empty middle name (most tables allow NULL/'').
    name_parts = full_name.split()
    if len(name_parts) >= 3:
        first_name, middle_name, last_name = name_parts[0], " ".join(name_parts[1:-1]), name_parts[-1]
    elif len(name_parts) == 2:
        first_name, middle_name, last_name = name_parts[0], "", name_parts[1]
    else:
        first_name, middle_name, last_name = full_name, "", ""

    password_hash = generate_password_hash(password)

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        if role in ("superadmin", "admin"):
            cursor.execute("SELECT admin_id FROM admins WHERE username = %s", (username,))
            if cursor.fetchone():
                return jsonify({"success": False, "reason": f"'{username}' already exists in admins"}), 409
            cursor.execute(
                "INSERT INTO admins (username, password_hash, email) VALUES (%s, %s, %s)",
                (username, password_hash, email),
            )

        elif role == "teacher":
            cursor.execute("SELECT uTID FROM teachers WHERE uTID = %s", (username,))
            if cursor.fetchone():
                return jsonify({"success": False, "reason": f"'{username}' already exists in teachers"}), 409
            cursor.execute(
                "INSERT INTO teachers (uTID, first_name, middle_name, last_name, email, password_hash) "
                "VALUES (%s, %s, %s, %s, %s, %s)",
                (username, first_name, middle_name, last_name, email, password_hash),
            )

        elif role == "student":
            cursor.execute("SELECT uSID FROM students WHERE uSID = %s", (username,))
            if cursor.fetchone():
                return jsonify({"success": False, "reason": f"'{username}' already exists in students"}), 409
            cursor.execute(
                "INSERT INTO students (uSID, first_name, middle_name, last_name, email, password_hash) "
                "VALUES (%s, %s, %s, %s, %s, %s)",
                (username, first_name, middle_name, last_name, email, password_hash),
            )

        conn.commit()
        return jsonify({"success": True}), 201

    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "reason": str(e)}), 500

    finally:
        cursor.close()
        conn.close()


# ── Endpoint 1: All active enrolled students ──────────────────────────────────
@nc_api.route('/students/active')
def get_active_students():
    """
    Returns all active students from NewChange.
    Consumed by: Voxify (alternative voter import source).
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT
                usid        AS student_id,
                first_name  AS firstname,
                middle_name AS middlename,
                last_name   AS lastname,
                email,
                course,
                level       AS year_level,
                section,
                status
            FROM Students
            WHERE status = 'Active'
            ORDER BY usid
        """)
        students = list(cursor.fetchall())
        cursor.close(); conn.close()
        return jsonify({"students": students, "count": len(students)})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ── Endpoint 2: Enrollment info for a student ─────────────────────────────────
@nc_api.route('/students/<student_id>/enrollment')
def get_enrollment(student_id):
    """
    Returns enrolled subjects/schedule for a student.
    Consumed by: TestPoint (to validate class assignments).
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Check student exists
        cursor.execute("SELECT * FROM Students WHERE usid = %s", (student_id,))
        student = cursor.fetchone()
        if not student:
            cursor.close(); conn.close()
            return jsonify({"error": "Student not found"}), 404

        cursor.execute("""
            SELECT
                e.enrollment_id,
                e.subject_id,
                sub.subject_name,
                sub.subject_code,
                ta.schedule,
                t.first_name || ' ' || t.last_name AS teacher_name
            FROM Enrollments e
            JOIN Teacher_Assignments ta ON e.subject_id = ta.subject_id
            JOIN Subjects sub ON e.subject_id = sub.subject_id
            JOIN Teachers t ON ta.utid = t.utid
            WHERE e.usid = %s
        """, (student_id,))
        enrollments = list(cursor.fetchall())
        cursor.close(); conn.close()

        return jsonify({
            "student_id": student_id,
            "firstname": student['first_name'],
            "lastname": student['last_name'],
            "course": student['course'],
            "year_level": student['level'],
            "section": student['section'],
            "enrolled_subjects": enrollments
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ── Endpoint 3: Attendance summary for a student ─────────────────────────────
@nc_api.route('/students/<student_id>/attendance')
def get_attendance(student_id):
    """
    Returns attendance rates per subject.
    Consumed by: Voxify (eligibility check before allowing voting — optional).
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT usid FROM Students WHERE usid = %s", (student_id,))
        if not cursor.fetchone():
            cursor.close(); conn.close()
            return jsonify({"error": "Student not found"}), 404

        cursor.execute("""
            SELECT
                sub.subject_code,
                sub.subject_name,
                COUNT(a.attendance_id)                              AS total_sessions,
                SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS attended,
                ROUND(
                    100.0 * SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END)
                    / NULLIF(COUNT(a.attendance_id), 0), 1
                ) AS attendance_rate
            FROM Attendance a
            JOIN Teacher_Assignments ta ON a.subject_id = ta.subject_id
            JOIN Subjects sub ON ta.subject_id = sub.subject_id
            WHERE a.usid = %s
            GROUP BY sub.subject_code, sub.subject_name
        """, (student_id,))
        attendance = list(cursor.fetchall())
        cursor.close(); conn.close()
        return jsonify({"student_id": student_id, "attendance": attendance})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ── Endpoint 4: Stats for integration hub ─────────────────────────────────────
@nc_api.route('/stats')
def get_stats():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT COUNT(*) AS c FROM Students WHERE status='Active'")
        students = cursor.fetchone()['c']
        cursor.execute("SELECT COUNT(*) AS c FROM Teachers WHERE status='Active'")
        teachers = cursor.fetchone()['c']
        cursor.execute("SELECT COUNT(*) AS c FROM Subjects")
        subjects = cursor.fetchone()['c']
        cursor.execute("SELECT COUNT(*) AS c FROM Enrollments")
        enrollments = cursor.fetchone()['c']
        cursor.close(); conn.close()
        return jsonify({
            "system": "NewChange",
            "active_students": students,
            "active_teachers": teachers,
            "total_subjects": subjects,
            "total_enrollments": enrollments
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ── Cross-system: Enroll a student after verifying with TestPoint ──────────────
@nc_api.route('/students/enroll-verified', methods=['POST'])
def enroll_verified():
    """
    Enrolls a student only if they exist and are active in TestPoint.
    Body: { "student_id": "S26-0001", "subject_id": 3 }
    """
    data = request.get_json(silent=True) or {}
    student_id = data.get('student_id')
    subject_id = data.get('subject_id')

    if not student_id or not subject_id:
        return jsonify({"error": "student_id and subject_id are required"}), 400

    # 1. Verify student in TestPoint
    try:
        resp = requests.get(f"{TESTPOINT_URL}/api/students/{student_id}", timeout=5)
        if resp.status_code == 404:
            return jsonify({"error": f"Student {student_id} not found in TestPoint"}), 404
        if resp.status_code != 200:
            return jsonify({"error": "Could not verify student in TestPoint"}), 502
        tp_student = resp.json()
    except requests.exceptions.RequestException as e:
        return jsonify({"error": f"TestPoint unreachable: {str(e)}"}), 503

    # 2. Enroll in NewChange
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Check subject exists
        cursor.execute("SELECT subject_id FROM Subjects WHERE subject_id = %s", (subject_id,))
        if not cursor.fetchone():
            cursor.close(); conn.close()
            return jsonify({"error": "Subject not found in NewChange"}), 404

        # Check already enrolled
        cursor.execute(
            "SELECT enrollment_id FROM Enrollments WHERE usid = %s AND subject_id = %s",
            (student_id, subject_id)
        )
        if cursor.fetchone():
            cursor.close(); conn.close()
            return jsonify({"message": "Student already enrolled in this subject"}), 200

        cursor.execute(
            "INSERT INTO Enrollments (usid, subject_id) VALUES (%s, %s) RETURNING enrollment_id",
            (student_id, subject_id)
        )
        eid = cursor.fetchone()['enrollment_id']
        conn.commit()
        cursor.close(); conn.close()

        return jsonify({
            "message": "Student enrolled successfully (verified via TestPoint)",
            "enrollment_id": eid,
            "student": tp_student
        }), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500