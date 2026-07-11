"""
Voxify Integration API
Exposes election data, voter status, and results for TestPoint and NewChange.
"""
from flask import Blueprint, jsonify, request, current_app, url_for
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


@voxify_api.route('/announcements')
def get_announcements():
    """
    Returns published Voxify announcements for partner modules.
    """
    try:
        college_id = request.args.get('college_id', type=int)
        conn = db()
        cursor = conn.cursor(dictionary=True)
        if college_id is not None:
            cursor.execute(
                """
                SELECT a.id, a.title, a.body, a.type, a.image_url, a.college_id,
                       c.name AS college_name,
                       a.created_by, a.status, a.created_at, a.updated_at
                FROM announcements a
                LEFT JOIN colleges c ON c.id = a.college_id
                WHERE a.status = 'published' AND (a.college_id = %s OR a.college_id IS NULL)
                ORDER BY a.created_at DESC
                """,
                (college_id,)
            )
        else:
            cursor.execute(
                """
                SELECT a.id, a.title, a.body, a.type, a.image_url, a.college_id,
                       c.name AS college_name,
                       a.created_by, a.status, a.created_at, a.updated_at
                FROM announcements a
                LEFT JOIN colleges c ON c.id = a.college_id
                WHERE a.status = 'published'
                ORDER BY a.created_at DESC
                """
            )
        rows = cursor.fetchall()
        for row in rows:
            if row.get('image_url'):
                row['image_url'] = request.host_url.rstrip('/') + url_for('admin.static', filename='uploads/announcements/' + row['image_url'])
        cursor.close(); conn.close()
        return jsonify({"announcements": [serialize(r) for r in rows], "count": len(rows)})
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
                "college_id": None,
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
            "college_id": voter['college_id'],
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


# ── Provision User (called by Attendance/TestPoint to mirror a user here) ─────
@voxify_api.route('/provision-user', methods=['POST'])
def provision_user():
    """
    Called by another module (Attendance, TestPoint) right after IT creates
    a user, so that same person gets a matching local row in db_voting.users
    too — letting them use Voxify with the same Portal identity.

    Voxify's 'voter' is equivalent to Portal's 'student'; 'teacher' is also
    mapped to 'voter' since Voxify has no teacher concept.

    college_id is resolved from an optional "college" name in the request
    body (matched case-insensitively against Voxify's colleges table; a
    new college row is created if no match exists). If no "college" is
    given, college_id is left NULL as before.

    Request body (JSON):
        {
            "username":  "<string>",   required — used as student_id
            "password":  "<string>",   required, PLAINTEXT
            "full_name": "<string>",   required — split into first/middle/last
            "role":      "<string>",   required — superadmin|admin|teacher|student
            "email":     "<string>",   optional
            "college":   "<string>",   optional — college name from the source module
        }

    Success response (201):  { "success": true }
    Failure response:        { "success": false, "reason": "<string>" }
    """
    from werkzeug.security import generate_password_hash

    body = request.get_json(silent=True) or {}

    username  = (body.get("username") or "").strip()
    password  = body.get("password") or ""
    full_name = (body.get("full_name") or "").strip()
    role      = (body.get("role") or "").strip()
    email     = body.get("email") or f"{username}@placeholder.local"
    college_name = (body.get("college") or "").strip()

    if not username or not password or not full_name:
        return jsonify({"success": False, "reason": "username, password, full_name are required"}), 400

    # Map Portal roles to Voxify's role vocabulary per mirroring matrix:
    #   superadmin → superadmin, admin → admin, student → voter
    #   teacher has NO Voxify role — reject, don't mirror here
    role_map = {
        "superadmin": "superadmin",
        "admin":      "admin",
        "student":    "voter",
    }
    voxify_role = role_map.get(role)
    if not voxify_role:
        return jsonify({"success": False, "reason": f"role '{role}' has no Voxify equivalent — teachers are not mirrored to Voxify"}), 400

    name_parts = full_name.split()
    if len(name_parts) >= 3:
        firstname, middlename, surname = name_parts[0], " ".join(name_parts[1:-1]), name_parts[-1]
    elif len(name_parts) == 2:
        firstname, middlename, surname = name_parts[0], "", name_parts[1]
    else:
        firstname, middlename, surname = full_name, "", ""

    hashed_password = generate_password_hash(password)

    try:
        conn = db()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT id FROM users WHERE student_id = %s", (username,))
        if cursor.fetchone():
            cursor.close(); conn.close()
            return jsonify({"success": False, "reason": f"'{username}' already exists in Voxify users"}), 409

        college_id = None
        if college_name:
            cursor.execute("SELECT id FROM colleges WHERE LOWER(name) = LOWER(%s)", (college_name,))
            existing = cursor.fetchone()
            if existing:
                college_id = existing["id"]
            else:
                cursor.execute("INSERT INTO colleges (name) VALUES (%s)", (college_name,))
                college_id = cursor.lastrowid

        cursor.execute(
            """INSERT INTO users
               (student_id, firstname, middlename, surname, email, password,
                role, college_id, is_approved, is_active, is_archived)
               VALUES (%s, %s, %s, %s, %s, %s, %s, %s, 1, 1, 0)""",
            (username, firstname, middlename, surname, email,
             hashed_password, voxify_role, college_id),
        )
        conn.commit()
        cursor.close(); conn.close()
        return jsonify({"success": True}), 201

    except Exception as e:
        return jsonify({"success": False, "reason": str(e)}), 500


# ── Update User (called by TestPoint to sync profile modifications here) ──────
@voxify_api.route("/update-user", methods=["POST"])
def update_user():
    """
    Called by TestPoint right after an admin updates a user profile.
    Updates the local voter or admin profile in db_voting.users.

    Request body (JSON):
        {
            "username":  "<string>",        required — used as student_id
            "role":      "<string>",        required — superadmin|admin|teacher|student
            "changed_fields": { ... }      required — fields delta
        }
    """
    from werkzeug.security import generate_password_hash

    body = request.get_json(silent=True) or {}
    username = (body.get("username") or "").strip()
    role = (body.get("role") or "").strip()
    changed_fields = body.get("changed_fields") or {}

    if not username or not changed_fields:
        return (
            jsonify(
                {"success": False, "reason": "username and changed_fields are required"}
            ),
            400,
        )

    # Map Portal/TestPoint roles to Voxify roles.
    # Voxify does not track 'teacher' profiles, so we acknowledge and skip gracefully.
    role_map = {
        "superadmin": "superadmin",
        "admin": "admin",
        "student": "voter",
    }
    voxify_role = role_map.get(role)
    if not voxify_role:
        return (
            jsonify({"success": True, "message": "Teachers are not tracked in Voxify"}),
            200,
        )

    try:
        conn = db()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT id FROM users WHERE student_id = %s", (username,))
        user_record = cursor.fetchone()
        if not user_record:
            cursor.close()
            conn.close()
            return (
                jsonify(
                    {
                        "success": False,
                        "reason": f"User '{username}' not found in Voxify",
                    }
                ),
                404,
            )

        update_clauses = []
        params = []

        # Name mapping updates
        first_name = changed_fields.get("firstname")
        last_name = changed_fields.get("lastname")
        middle_name = changed_fields.get("middlename")

        if first_name is not None:
            update_clauses.append("firstname = %s")
            params.append(first_name)
        if middle_name is not None:
            update_clauses.append("middlename = %s")
            params.append(middle_name)
        if last_name is not None:
            update_clauses.append("surname = %s")
            params.append(last_name)

        if "email" in changed_fields:
            update_clauses.append("email = %s")
            params.append(changed_fields["email"])

        if "password" in changed_fields:
            update_clauses.append("password = %s")
            params.append(generate_password_hash(changed_fields["password"]))

        if "is_active" in changed_fields:
            update_clauses.append("is_active = %s")
            params.append(int(changed_fields["is_active"]))

        if "college" in changed_fields:
            college_name = changed_fields["college"]
            if college_name:
                # Flexible matching: Map abbreviations or program acronyms back to voting database college names.
                abbr_map = {
                    "CCS": "Computer Studies",
                    "COED": "Education",
                    "COED1Q": "Education",
                    "BSIT": "Computer Studies",
                    "BSCS": "Computer Studies",
                    "BSED": "Education",
                }
                search_term = abbr_map.get(college_name, college_name)
                cursor.execute(
                    "SELECT id FROM colleges WHERE name LIKE %s OR name = %s",
                    (f"%{search_term}%", college_name),
                )
                col_row = cursor.fetchone()
                if col_row:
                    update_clauses.append("college_id = %s")
                    params.append(col_row["id"])
                else:
                    update_clauses.append("college_id = NULL")
            else:
                update_clauses.append("college_id = NULL")

        if update_clauses:
            query = (
                f"UPDATE users SET {', '.join(update_clauses)} WHERE student_id = %s"
            )
            params.append(username)
            cursor.execute(query, tuple(params))
            conn.commit()

        cursor.close()
        conn.close()
        return jsonify({"success": True}), 200

    except Exception as e:
        return jsonify({"success": False, "reason": str(e)}), 500

# ── Backfill college on an already-mirrored user (called by TestPoint) ────────
@voxify_api.route("/sync-user-college", methods=["POST"])
def sync_user_college():
    """
    Updates college_id on a user that was already mirrored to Voxify
    before college syncing existed (or was created without a block
    assigned yet). Looked up by student_id ('username' in the payload).

    Request body (JSON):
        { "username": "<string>", "college": "<string>" }

    Success response (200): { "success": true, "updated": true/false }
    """
    body = request.get_json(silent=True) or {}
    username = (body.get("username") or "").strip()
    college_name = (body.get("college") or "").strip()

    if not username or not college_name:
        return (
            jsonify({"success": False, "reason": "username and college are required"}),
            400,
        )

    try:
        conn = db()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            "SELECT id, college_id FROM users WHERE student_id = %s", (username,)
        )
        user = cursor.fetchone()
        if not user:
            cursor.close()
            conn.close()
            return (
                jsonify(
                    {
                        "success": False,
                        "reason": f"'{username}' not found in Voxify users",
                    }
                ),
                404,
            )

        cursor.execute(
            "SELECT id FROM colleges WHERE LOWER(name) = LOWER(%s)", (college_name,)
        )
        existing = cursor.fetchone()
        if existing:
            college_id = existing["id"]
        else:
            cursor.execute("INSERT INTO colleges (name) VALUES (%s)", (college_name,))
            college_id = cursor.lastrowid

        updated = user["college_id"] != college_id
        if updated:
            cursor.execute(
                "UPDATE users SET college_id = %s WHERE id = %s",
                (college_id, user["id"]),
            )
            conn.commit()

        cursor.close()
        conn.close()
        return jsonify({"success": True, "updated": updated}), 200

    except Exception as e:
        return jsonify({"success": False, "reason": str(e)}), 500


# ── Sync a single college (called by TestPoint, no user attached) ─────────────
@voxify_api.route('/sync-college', methods=['POST'])
def sync_college():
    """
    Upserts a college by name — used to import TestPoint's college list
    into Voxify wholesale (so the SuperAdmin's college dropdown is
    populated even before any student from that college exists yet).
    Colleges are no longer created manually in Voxify — TestPoint is the
    source of truth; this is the only way a new one should appear here.

    Request body (JSON): { "college_name": "<string>" }
    Success response (201, whether newly created or already existed): { "success": true, "college_id": <int> }
    """
    body = request.get_json(silent=True) or {}
    college_name = (body.get("college_name") or "").strip()
    if not college_name:
        return jsonify({"success": False, "reason": "college_name is required"}), 400

    try:
        conn = db()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT id FROM colleges WHERE LOWER(name) = LOWER(%s)", (college_name,))
        existing = cursor.fetchone()
        if existing:
            cursor.close(); conn.close()
            return jsonify({"success": True, "college_id": existing["id"]}), 201

        cursor.execute("INSERT INTO colleges (name) VALUES (%s)", (college_name,))
        conn.commit()
        college_id = cursor.lastrowid
        cursor.close(); conn.close()
        return jsonify({"success": True, "college_id": college_id}), 201

    except Exception as e:
        return jsonify({"success": False, "reason": str(e)}), 500
