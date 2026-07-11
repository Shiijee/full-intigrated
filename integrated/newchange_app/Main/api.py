"""
NewChange Integration API
Exposes enrollment, attendance, and student data.
Also consumes APIs from TestPoint and Voxify.
"""
from flask import Blueprint, jsonify, request
import os
import requests
from Main.db import get_db_connection
from werkzeug.security import generate_password_hash

nc_api = Blueprint('nc_api', __name__, url_prefix='/api')

# URLs for partner systems — update with actual IPs on demo day
TESTPOINT_URL = os.getenv("TESTPOINT_URL", "http://127.0.0.1:5003")
VOXIFY_URL    = os.getenv("VOXIFY_URL",    "http://127.0.0.1:5001")


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
            "username":  "<string>",   required — used as user_id,
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
                cursor.execute("UPDATE admins SET email = %s WHERE username = %s", (email, username))
            else:
                cursor.execute(
                    "INSERT INTO admins (username, password_hash, email) VALUES (%s, %s, %s)",
                    (username, password_hash, email),
                )

        elif role == "teacher":
            department = body.get("department", "")
            cursor.execute("SELECT user_id FROM teachers WHERE user_id = %s", (username,))
            if cursor.fetchone():
                cursor.execute(
                    "UPDATE teachers SET first_name = %s, middle_name = %s, last_name = %s, department = %s, email = %s WHERE user_id = %s",
                    (first_name, middle_name or "", last_name, department, email, username)
                )
            else:
                cursor.execute(
                    "INSERT INTO teachers (user_id, user_role, first_name, middle_name, last_name, department, email, password_hash) "
                    "VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
                    (username, "teacher", first_name, middle_name or "", last_name, department, email, password_hash),
                )

        elif role == "student":
            program = body.get("program", "")
            college = body.get("college", "")
            year = body.get("year", "")
            block = body.get("block", "")
            cursor.execute("SELECT user_id FROM students WHERE user_id = %s", (username,))
            if cursor.fetchone():
                cursor.execute(
                    "UPDATE students SET first_name = %s, middle_name = %s, last_name = %s, email = %s, program = %s, college = %s, year = %s, block = %s WHERE user_id = %s",
                    (first_name, middle_name or "", last_name, email, program, college, year, block, username)
                )
            else:
                cursor.execute(
                    "INSERT INTO students (user_id, first_name, middle_name, last_name, email, program, college, year, block, password_hash) "
                    "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                    (username, first_name, middle_name or "", last_name, email, program, college, year, block, password_hash),
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
                user_id     AS student_id,
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
            ORDER BY user_id
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
        cursor.execute("SELECT * FROM Students WHERE user_id = %s", (student_id,))
        student = cursor.fetchone()
        if not student:
            cursor.close(); conn.close()
            return jsonify({"error": "Student not found"}), 404

        cursor.execute("""
            SELECT
                e.enrollment_id,
                ta.subject_id,
                sub.subject_name,
                sub.subject_code,
                ta.section,
                CONCAT(t.first_name, ' ', t.last_name) AS teacher_name
            FROM Enrollments e
            JOIN Teacher_Assignments ta ON e.assignment_id = ta.assignment_id
            JOIN Subjects sub ON ta.subject_id = sub.subject_id
            JOIN Teachers t ON ta.teacher_id = t.user_id
            WHERE e.user_id = %s
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
        cursor.execute("SELECT user_id FROM Students WHERE user_id = %s", (student_id,))
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
            JOIN Sessions ses ON a.session_id = ses.session_id
            JOIN Subjects sub ON ses.subject_id = sub.subject_id
            WHERE a.user_id = %s
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
    Body: { "student_id": "S26-0001", "assignment_id": 3 }
    """
    data = request.get_json(silent=True) or {}
    student_id = data.get('student_id')
    assignment_id = data.get('assignment_id') or data.get('subject_id')

    if not student_id or not assignment_id:
        return jsonify({"error": "student_id and assignment_id are required"}), 400

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

        # Check assignment (subject+section+teacher) exists
        cursor.execute("SELECT assignment_id FROM Teacher_Assignments WHERE assignment_id = %s", (assignment_id,))
        if not cursor.fetchone():
            cursor.close(); conn.close()
            return jsonify({"error": "Assignment not found in NewChange"}), 404

        # Check already enrolled
        cursor.execute(
            "SELECT enrollment_id FROM Enrollments WHERE user_id = %s AND assignment_id = %s",
            (student_id, assignment_id)
        )
        if cursor.fetchone():
            cursor.close(); conn.close()
            return jsonify({"message": "Student already enrolled in this subject"}), 200

        cursor.execute(
            "INSERT INTO Enrollments (user_id, assignment_id) VALUES (%s, %s)",
            (student_id, assignment_id)
        )
        eid = cursor.lastrowid
        conn.commit()
        cursor.close(); conn.close()

        return jsonify({
            "message": "Student enrolled successfully (verified via TestPoint)",
            "enrollment_id": eid,
            "student": tp_student
        }), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@nc_api.route('/sync-subject', methods=['POST'])
def sync_subject():
    body = request.get_json(silent=True) or {}
    subject_code = body.get('subject_code')
    subject_name = body.get('subject_name')
    
    if not subject_code or not subject_name:
        return jsonify({"success": False, "reason": "Missing fields"}), 400
        
    conn = get_db_connection()
    if not conn:
        return jsonify({"success": False, "reason": "Database connection failed"}), 500
        
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT subject_id FROM Subjects WHERE subject_code = %s", (subject_code,))
        if cursor.fetchone():
            cursor.execute("UPDATE Subjects SET subject_name = %s WHERE subject_code = %s", 
                           (subject_name, subject_code))
        else:
            cursor.execute("INSERT INTO Subjects (subject_code, subject_name) VALUES (%s, %s)",
                           (subject_code, subject_name))
        conn.commit()
    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "reason": str(e)}), 500
    finally:
        cursor.close()
        conn.close()
        
    return jsonify({"success": True}), 201


@nc_api.route('/sync-class', methods=['POST'])
def sync_class():
    body = request.get_json(silent=True) or {}
    class_code = body.get('class_code')
    teacher_id = body.get('teacher_id')
    course_code = body.get('course_code')
    
    if not class_code or not teacher_id or not course_code:
        return jsonify({"success": False, "reason": "Missing fields"}), 400
        
    conn = get_db_connection()
    if not conn:
        return jsonify({"success": False, "reason": "Database connection failed"}), 500
        
    try:
        cursor = conn.cursor()
        # Find subject_id from course_code
        cursor.execute("SELECT subject_id FROM Subjects WHERE subject_code = %s", (course_code,))
        subject = cursor.fetchone()
        if not subject:
            return jsonify({"success": False, "reason": f"Subject {course_code} not found in newchange_app"}), 400
        subject_id = subject[0] if type(subject) is tuple else subject.get('subject_id')
        
        cursor.execute("SELECT assignment_id FROM Teacher_Assignments WHERE section = %s", (class_code,))
        if cursor.fetchone():
            cursor.execute("UPDATE Teacher_Assignments SET teacher_id = %s, subject_id = %s WHERE section = %s", 
                           (teacher_id, subject_id, class_code))
        else:
            cursor.execute("INSERT INTO Teacher_Assignments (teacher_id, subject_id, section) VALUES (%s, %s, %s)",
                           (teacher_id, subject_id, class_code))
        conn.commit()
    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "reason": str(e)}), 500
    finally:
        cursor.close()
        conn.close()
        
    return jsonify({"success": True}), 201


@nc_api.route('/sync-enrollment', methods=['POST'])
def sync_enrollment():
    body = request.get_json(silent=True) or {}
    user_id = body.get('user_id')
    class_code = body.get('class_code')
    
    if not user_id or not class_code:
        return jsonify({"success": False, "reason": "Missing fields"}), 400
        
    conn = get_db_connection()
    if not conn:
        return jsonify({"success": False, "reason": "Database connection failed"}), 500
        
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT assignment_id FROM Teacher_Assignments WHERE class_code = %s", (class_code,))
        assignment = cursor.fetchone()
        if not assignment:
            return jsonify({"success": False, "reason": f"Class {class_code} not found in newchange_app"}), 400
        assignment_id = assignment['assignment_id']

        cursor.execute("SELECT enrollment_id FROM Enrollments WHERE user_id = %s AND assignment_id = %s", (user_id, assignment_id))
        if not cursor.fetchone():
            cursor.execute("INSERT INTO Enrollments (user_id, assignment_id) VALUES (%s, %s)", (user_id, assignment_id))
        conn.commit()
    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "reason": str(e)}), 500
    finally:
        if cursor: cursor.close()
        if conn: conn.close()
        
    return jsonify({"success": True})

@nc_api.route('/sync-unenroll', methods=['POST'])
def sync_unenroll():
    body = request.get_json(silent=True) or {}
    user_id = body.get('user_id')
    class_code = body.get('class_code')
    
    if not user_id or not class_code:
        return jsonify({"success": False, "reason": "Missing fields"}), 400
        
    conn = get_db_connection()
    if not conn:
        return jsonify({"success": False, "reason": "Database connection failed"}), 500
        
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT assignment_id FROM Teacher_Assignments WHERE class_code = %s", (class_code,))
        assignment = cursor.fetchone()
        if not assignment:
            return jsonify({"success": False, "reason": f"Class {class_code} not found"}), 400
        assignment_id = assignment['assignment_id']

        cursor.execute("DELETE FROM Enrollments WHERE user_id = %s AND assignment_id = %s", (user_id, assignment_id))
        conn.commit()
    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "reason": str(e)}), 500
    finally:
        if cursor: cursor.close()
        if conn: conn.close()
        
    return jsonify({"success": True}), 201


@nc_api.route('/provision-subject', methods=['POST'])
def provision_subject():
    '''
    Webhook called by TestPoint to sync courses (subjects).
    '''
    data = request.json
    if not data:
        return jsonify({"error": "No JSON payload"}), 400
        
    subject_code = data.get('subject_code')
    subject_name = data.get('subject_name')
    is_active = data.get('is_active', True)

    if not subject_code or not subject_name:
        return jsonify({"error": "Missing required fields (subject_code, subject_name)"}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database error"}), 500

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT subject_id FROM Subjects WHERE subject_code = %s", (subject_code,))
        existing = cursor.fetchone()

        # In TestPoint, it's is_active. In NewChange, it's is_archived (inverted).
        is_archived = 0 if is_active in [1, True, "1", "true"] else 1

        if existing:
            # Update existing subject
            cursor.execute("""
                UPDATE Subjects
                SET subject_name = %s, is_archived = %s
                WHERE subject_code = %s
            """, (subject_name, is_archived, subject_code))
        else:
            # Insert new subject
            cursor.execute("""
                INSERT INTO Subjects (subject_code, subject_name, is_archived)
                VALUES (%s, %s, %s)
            """, (subject_code, subject_name, is_archived))
        
        conn.commit()
        return jsonify({"success": True, "message": "Subject synced successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if cursor: cursor.close()
        if conn: conn.close()


@nc_api.route('/provision-class', methods=['POST'])
def provision_class():
    '''
    Webhook called by TestPoint to sync classes (Teacher_Assignments).
    '''
    data = request.json
    if not data:
        return jsonify({"error": "No JSON payload"}), 400
        
    class_code = data.get('class_code')
    course_code = data.get('course_code')
    section = data.get('block_name')
    teacher_id = data.get('teacher_id')
    is_active = data.get('is_active', 1)

    if not class_code or not course_code:
        return jsonify({"error": "Missing required fields (class_code, course_code)"}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database error"}), 500

    try:
        cursor = conn.cursor(dictionary=True)
        
        # 1. Lookup subject_id
        cursor.execute("SELECT subject_id FROM Subjects WHERE subject_code = %s", (course_code,))
        subject = cursor.fetchone()
        if not subject:
            return jsonify({"error": f"Subject {course_code} not found in NewChange"}), 404
        subject_id = subject['subject_id']

        # 2. Check if Teacher_Assignment exists by class_code
        cursor.execute("SELECT assignment_id FROM Teacher_Assignments WHERE class_code = %s", (class_code,))
        existing = cursor.fetchone()

        is_archived = 0 if is_active in [1, True, "1", "true"] else 1

        if existing:
            # Update existing assignment
            cursor.execute("""
                UPDATE Teacher_Assignments
                SET teacher_id = %s, subject_id = %s, section = %s, is_archived = %s
                WHERE class_code = %s
            """, (teacher_id, subject_id, section, is_archived, class_code))
        else:
            # Insert new assignment
            cursor.execute("""
                INSERT INTO Teacher_Assignments (class_code, teacher_id, subject_id, section, is_archived)
                VALUES (%s, %s, %s, %s, %s)
            """, (class_code, teacher_id, subject_id, section, is_archived))
        
        conn.commit()
        return jsonify({"success": True, "message": "Class synced successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if cursor: cursor.close()
        if conn: conn.close()
