"""
Voxify Integration API
Exposes election data, voter status, and results for TestPoint and NewChange.
"""
from flask import Blueprint, jsonify, request, current_app
import requests
from datetime import datetime

voxify_api = Blueprint('voxify_api', __name__, url_prefix='/api')

# URLs for other systems — update with actual IPs on demo day
TESTPOINT_URL = "http://127.0.0.1:5000"
NEWCHANGE_URL = "http://127.0.0.1:5002"


def db():
    return current_app.config["get_db_connection"]()


def serialize(obj):
    """Make MySQL results JSON-serializable."""
    if isinstance(obj, dict):
        return {k: (str(v) if isinstance(v, (datetime,)) else v) for k, v in obj.items()}
    return obj


@voxify_api.route('/ping')
def ping():
    return jsonify({"system": "Voxify", "status": "ok"})


# ── Endpoint 1: List all elections ───────────────────────────────────────────
@voxify_api.route('/elections')
def get_elections():
    """
    Returns all elections with turnout info.
    Consumed by: TestPoint dashboard, NewChange dashboard, Integration Hub.
    """
    try:
        conn = db()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT
                e.id          AS election_id,
                e.title       AS election_title,
                e.start_date,
                e.end_date,
                e.status,
                e.college_id,
                c.name        AS college_name,
                COUNT(DISTINCT u.id)        AS total_voters,
                SUM(u.has_voted)            AS votes_cast
            FROM elections e
            LEFT JOIN colleges c ON e.college_id = c.id
            LEFT JOIN users u ON u.college_id = e.college_id AND u.role = 'voter' AND u.is_archived = 0
            GROUP BY e.id
            ORDER BY e.start_date DESC
        """)
        rows = cursor.fetchall()
        cursor.close(); conn.close()
        elections = [serialize(r) for r in rows]
        # Compute turnout percentage
        for el in elections:
            tv = el.get('total_voters') or 0
            vc = el.get('votes_cast') or 0
            el['turnout_pct'] = round((vc / tv * 100), 1) if tv else 0
        return jsonify({"elections": elections, "count": len(elections)})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ── Endpoint 2: Election results ─────────────────────────────────────────────
@voxify_api.route('/elections/<int:election_id>/results')
def get_results(election_id):
    """
    Returns vote tallies per position/candidate for an election.
    Consumed by: Integration Hub results panel.
    """
    try:
        conn = db()
        cursor = conn.cursor(dictionary=True)
        # Check election exists
        cursor.execute("SELECT id, title, status FROM elections WHERE id = %s", (election_id,))
        election = cursor.fetchone()
        if not election:
            cursor.close(); conn.close()
            return jsonify({"error": "Election not found"}), 404

        cursor.execute("""
            SELECT
                p.id    AS position_id,
                p.title AS position_title,
                c.id    AS candidate_id,
                c.firstname,
                c.surname,
                c.partylist,
                COUNT(v.id) AS vote_count
            FROM positions p
            JOIN candidates c ON c.position_id = p.id
            LEFT JOIN votes v ON v.candidate_id = c.id AND v.election_id = %s
            WHERE p.election_id = %s
            GROUP BY p.id, c.id
            ORDER BY p.id, vote_count DESC
        """, (election_id, election_id))
        rows = cursor.fetchall()
        cursor.close(); conn.close()

        # Group by position
        positions = {}
        for row in rows:
            pid = row['position_id']
            if pid not in positions:
                positions[pid] = {"position_id": pid, "position": row['position_title'], "candidates": []}
            positions[pid]['candidates'].append({
                "candidate_id": row['candidate_id'],
                "name": f"{row['firstname']} {row['surname']}",
                "partylist": row['partylist'],
                "votes": row['vote_count']
            })

        return jsonify({
            "election_id": election_id,
            "election_title": election['title'],
            "status": election['status'],
            "results": list(positions.values())
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ── Endpoint 3: Voter status by student_id ───────────────────────────────────
@voxify_api.route('/voters/status/<student_id>')
def voter_status(student_id):
    """
    Checks if a student is a registered voter and whether they've voted.
    Consumed by: TestPoint student dashboard (show voting reminder/badge).
    """
    try:
        conn = db()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT
                u.id,
                u.student_id,
                u.has_voted,
                u.college_id,
                u.is_approved
            FROM users u
            WHERE u.student_id = %s AND u.role = 'voter'
            LIMIT 1
        """, (student_id,))
        voter = cursor.fetchone()

        if not voter:
            cursor.close(); conn.close()
            return jsonify({
                "student_id": student_id,
                "is_registered_voter": False,
                "has_voted": False,
                "election_id": None,
                "election_title": None
            })

        # Find their active/recent election
        cursor.execute("""
            SELECT id, title, status
            FROM elections
            WHERE college_id = %s
              AND status IN ('active','completed','closed')
            ORDER BY start_date DESC
            LIMIT 1
        """, (voter['college_id'],))
        election = cursor.fetchone()
        cursor.close(); conn.close()

        return jsonify({
            "student_id": student_id,
            "is_registered_voter": bool(voter['is_approved']),
            "has_voted": bool(voter['has_voted']),
            "election_id": election['id'] if election else None,
            "election_title": election['title'] if election else None
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ── Endpoint 4: Import students from TestPoint as voters ─────────────────────
@voxify_api.route('/voters/import-from-testpoint', methods=['POST'])
def import_voters():
    """
    Admin-triggered: pulls active students from TestPoint and registers
    them as voters in Voxify for a given college_id.
    Body: { "college_id": 1, "default_password": "Voter@2026" }
    """
    from werkzeug.security import generate_password_hash

    data = request.get_json(silent=True) or {}
    college_id = data.get('college_id')
    default_password = data.get('default_password', 'Voter@2026')

    if not college_id:
        return jsonify({"error": "college_id is required"}), 400

    # Fetch students from TestPoint
    try:
        resp = requests.get(f"{TESTPOINT_URL}/api/students", timeout=5)
        if resp.status_code != 200:
            return jsonify({"error": "Failed to fetch students from TestPoint", "detail": resp.text}), 502
        students = resp.json().get('students', [])
    except requests.exceptions.RequestException as e:
        return jsonify({"error": f"TestPoint unreachable: {str(e)}"}), 503

    conn = db()
    cursor = conn.cursor(dictionary=True)
    imported = 0
    skipped = 0

    for s in students:
        student_id = s.get('student_id')
        if not student_id:
            continue
        # Skip if already exists
        cursor.execute("SELECT id FROM users WHERE student_id = %s AND role = 'voter'", (student_id,))
        if cursor.fetchone():
            skipped += 1
            continue

        email = s.get('email') or f"{student_id.lower().replace('-','')}@testpoint.edu"
        firstname = s.get('firstname', '')
        middlename = s.get('middlename', '') or ''
        surname = s.get('lastname', '')
        pw_hash = generate_password_hash(default_password)

        cursor.execute("""
            INSERT INTO users
                (student_id, firstname, middlename, surname, email, password, role,
                 college_id, is_approved, is_active, has_voted)
            VALUES (%s,%s,%s,%s,%s,%s,'voter',%s,1,1,0)
        """, (student_id, firstname, middlename, surname, email, pw_hash, college_id))
        imported += 1

    conn.commit()
    cursor.close(); conn.close()

    return jsonify({
        "message": f"Import complete. {imported} students imported, {skipped} already existed.",
        "imported": imported,
        "skipped": skipped
    })


# ── Endpoint 5: Stats for integration hub ────────────────────────────────────
@voxify_api.route('/stats')
def get_stats():
    try:
        conn = db()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT COUNT(*) as c FROM elections WHERE status='active'")
        active = cursor.fetchone()['c']
        cursor.execute("SELECT COUNT(*) as c FROM elections")
        total_e = cursor.fetchone()['c']
        cursor.execute("SELECT COUNT(*) as c FROM users WHERE role='voter' AND is_active=1")
        voters = cursor.fetchone()['c']
        cursor.execute("SELECT COUNT(*) as c FROM votes")
        votes = cursor.fetchone()['c']
        cursor.close(); conn.close()
        return jsonify({
            "system": "Voxify",
            "active_elections": active,
            "total_elections": total_e,
            "registered_voters": voters,
            "total_votes_cast": votes
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500
