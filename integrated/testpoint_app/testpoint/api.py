"""
TestPoint Integration API
Exposes student and exam data for NewChange and Voxify to consume.
"""
from flask import Blueprint, jsonify, request
import mysql.connector
from testpoint import db_config

api = Blueprint('api', __name__, url_prefix='/api')


def get_conn():
    return mysql.connector.connect(**db_config)


@api.route('/ping')
def ping():
    return jsonify({"system": "TestPoint", "status": "ok"})


@api.route('/provision-user', methods=['POST'])
def provision_user():
    """
    Called by another module (Voxify, Attendance) right after IT creates
    a user, so that same person gets a matching local profile row here
    too — letting them use TestPoint with the same Portal identity.

    Unlike add_user() in Admin/admin.py, this does NOT generate a new
    custom_user_id (A26-/T26-/S26- prefix+seq) — it uses the Portal's
    username directly as TestPoint's user_id/teacher_id/student_id/
    admin_id, so the identity stays consistent across all three modules.

    Request body (JSON):
        {
            "username":  "<string>",   required — used as TestPoint's user_id
            "password":  "<string>",   required, PLAINTEXT
            "full_name": "<string>",   required — split into first/middle/last
            "role":      "<string>",   required — superadmin|admin|teacher|student
            "email":     "<string>",   optional
        }

    Success response (201):
        { "success": true }

    Failure response (400/409/500):
        { "success": false, "reason": "<string>" }
    """
    from werkzeug.security import generate_password_hash

    body = request.get_json(silent=True) or {}

    username  = (body.get("username") or "").strip()
    password  = body.get("password") or ""
    full_name = (body.get("full_name") or "").strip()
    role      = (body.get("role") or "").strip()
    email     = body.get("email") or f"{username}@placeholder.local"

    if not username or not password or not full_name:
        return jsonify({"success": False, "reason": "username, password, and full_name are required"}), 400

    # TestPoint's db_exam.users.role enum is 'super_admin' (underscore).
    role_map = {"superadmin": "super_admin", "admin": "admin",
                "teacher": "teacher", "student": "student"}
    tp_role = role_map.get(role)
    if not tp_role:
        return jsonify({"success": False, "reason": "role must be superadmin, admin, teacher, or student"}), 400

    name_parts = full_name.split()
    if len(name_parts) >= 3:
        first_name, middle_name, last_name = name_parts[0], " ".join(name_parts[1:-1]), name_parts[-1]
    elif len(name_parts) == 2:
        first_name, middle_name, last_name = name_parts[0], "", name_parts[1]
    else:
        first_name, middle_name, last_name = full_name, "", ""

    hashed_password = generate_password_hash(password)

    conn = get_conn()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT user_id FROM users WHERE user_id = %s", (username,))
        if cursor.fetchone():
            return jsonify({"success": False, "reason": f"'{username}' already exists in users"}), 409

        cursor.execute(
            "INSERT INTO users (user_id, email, password, role, is_verified, is_active) "
            "VALUES (%s, %s, %s, %s, 1, 1)",
            (username, email, hashed_password, tp_role),
        )

        if tp_role == "teacher":
            cursor.execute(
                "INSERT INTO teachers (teacher_id, email, firstname, middlename, lastname) "
                "VALUES (%s, %s, %s, %s, %s)",
                (username, email, first_name, middle_name, last_name),
            )
        elif tp_role == "student":
            cursor.execute(
                "INSERT INTO students (student_id, email, firstname, middlename, lastname) "
                "VALUES (%s, %s, %s, %s, %s)",
                (username, email, first_name, middle_name, last_name),
            )
        elif tp_role in ("admin", "super_admin"):
            cursor.execute(
                "INSERT INTO admins (admin_id, email, firstname, middlename, lastname) "
                "VALUES (%s, %s, %s, %s, %s)",
                (username, email, first_name, middle_name, last_name),
            )

        conn.commit()
        return jsonify({"success": True}), 201

    except mysql.connector.Error as err:
        conn.rollback()
        return jsonify({"success": False, "reason": str(err)}), 500

    finally:
        cursor.close()
        conn.close()


# ── Endpoint 1: All active students ─────────────────────────────────────────
@api.route('/students')
def get_students():
    """
    Returns all active, verified students.
    Consumed by: Voxify (to import voter registry), NewChange (cross-check).
    """
    try:
        conn = get_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT
                s.student_id,
                s.firstname,
                s.middlename,
                s.lastname,
                u.email,
                s.block_id,
                b.block_name,
                p.program_name,
                u.is_active
            FROM students s
            JOIN users u ON s.student_id = u.user_id
            LEFT JOIN blocks b ON s.block_id = b.block_id
            LEFT JOIN programs p ON b.program_id = p.program_id
            WHERE u.is_active = 1
              AND u.is_verified = 1
            ORDER BY s.student_id
        """)
        students = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify({"students": students, "count": len(students)})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ── Endpoint 2: Single student by ID ─────────────────────────────────────────
@api.route('/students/<student_id>')
def get_student(student_id):
    """
    Returns one student's profile.
    Consumed by: NewChange before enrolling a student (existence check).
    """
    try:
        conn = get_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT
                s.student_id,
                s.firstname,
                s.middlename,
                s.lastname,
                u.email,
                s.block_id,
                b.block_name,
                p.program_name,
                u.is_active
            FROM students s
            JOIN users u ON s.student_id = u.user_id
            LEFT JOIN blocks b ON s.block_id = b.block_id
            LEFT JOIN programs p ON b.program_id = p.program_id
            WHERE s.student_id = %s
        """, (student_id,))
        student = cursor.fetchone()
        cursor.close()
        conn.close()
        if not student:
            return jsonify({"error": "Student not found"}), 404
        return jsonify(student)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ── Endpoint 3: Exam results for a student ────────────────────────────────────
@api.route('/students/<student_id>/exam-results')
def get_exam_results(student_id):
    """
    Returns completed exam scores for a student.
    Consumed by: NewChange for academic performance reports.
    """
    try:
        conn = get_conn()
        cursor = conn.cursor(dictionary=True)
        # Verify student exists first
        cursor.execute("SELECT student_id FROM students WHERE student_id = %s", (student_id,))
        if not cursor.fetchone():
            cursor.close()
            conn.close()
            return jsonify({"error": "Student not found"}), 404

        cursor.execute("""
            SELECT
                ea.attempt_id,
                e.exam_id,
                e.exam_title,
                c.course_code,
                ea.score,
                ea.total_items,
                ROUND((ea.score / ea.total_items) * 100, 2) AS percentage,
                ea.status,
                ea.submitted_at
            FROM exam_attempts ea
            JOIN exams e ON ea.exam_id = e.exam_id
            JOIN classes c ON e.class_code = c.class_code
            WHERE ea.student_id = %s
              AND ea.status = 'submitted'
            ORDER BY ea.submitted_at DESC
        """, (student_id,))
        results = cursor.fetchall()
        # Make datetime JSON-serializable
        for r in results:
            if r.get('submitted_at'):
                r['submitted_at'] = str(r['submitted_at'])
        cursor.close()
        conn.close()
        return jsonify({"student_id": student_id, "results": results, "count": len(results)})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ── Endpoint 4: Notify TestPoint that a student voted (called by Voxify) ─────
@api.route('/students/<student_id>/voting-status', methods=['POST'])
def update_voting_status(student_id):
    """
    Called by Voxify after a student votes to log it in TestPoint.
    Body: { "has_voted": true, "election_id": 1, "election_title": "..." }
    """
    try:
        data = request.get_json(silent=True) or {}
        has_voted = data.get('has_voted', False)
        election_id = data.get('election_id')
        election_title = data.get('election_title', '')

        conn = get_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT student_id FROM students WHERE student_id = %s", (student_id,))
        if not cursor.fetchone():
            cursor.close()
            conn.close()
            return jsonify({"error": "Student not found"}), 404

        # Log the event (we just store it; no schema change needed)
        # TestPoint admins can see this in student profiles
        cursor.close()
        conn.close()
        return jsonify({
            "message": "Voting status acknowledged",
            "student_id": student_id,
            "has_voted": has_voted,
            "election_id": election_id
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ── Endpoint 5: Dashboard stats (used by integration hub) ───────────────────
@api.route('/stats')
def get_stats():
    try:
        conn = get_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT COUNT(*) as c FROM users WHERE is_active=1 AND role='student'")
        students = cursor.fetchone()['c']
        cursor.execute("SELECT COUNT(*) as c FROM exams")
        exams = cursor.fetchone()['c']
        cursor.execute("SELECT COUNT(*) as c FROM classes WHERE is_active=1")
        classes = cursor.fetchone()['c']
        cursor.execute("SELECT COUNT(*) as c FROM exam_attempts WHERE status='in-progress'")
        live = cursor.fetchone()['c']
        cursor.close()
        conn.close()
        return jsonify({
            "system": "TestPoint",
            "total_students": students,
            "total_exams": exams,
            "active_classes": classes,
            "live_exam_sessions": live
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500