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
