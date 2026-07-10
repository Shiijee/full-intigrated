"""
voxify_app/Voxify/portal_sync.py
=================================
Helper that pushes newly-created users to the Portal's unified
`users` table, so they can immediately log in via SSO across
all modules.

Call this right after a module successfully creates a local user,
using the PLAINTEXT password (the Portal does its own storage/hash
strategy — currently a plain equality check, matching portal/app.py).
"""

import os
import json
import time
import requests
import urllib3

# NewChange serves HTTPS using a self-signed cert — verify=False is needed for
# calls to it below, or every request raises SSLCertVerificationError.
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

PORTAL_URL          = os.getenv("PORTAL_URL", "http://127.0.0.1:5000")
CREATE_USER_ENDPOINT = f"{PORTAL_URL}/api/create-user"

TESTPOINT_URL            = os.getenv("TESTPOINT_URL", "http://127.0.0.1:5003")
TESTPOINT_PROVISION_URL  = f"{TESTPOINT_URL}/api/provision-user"

ATTENDANCE_URL           = os.getenv("ATTENDANCE_URL", "https://127.0.0.1:5002")
ATTENDANCE_PROVISION_URL = f"{ATTENDANCE_URL}/api/provision-user"

_RETRY_ATTEMPTS = 3
_RETRY_DELAY_S  = 2  # seconds between attempts — covers "the other app is still booting"


def _get_voxify_db_connection():
    """Lazy import to avoid a circular import with Voxify's __init__.py."""
    from Voxify import get_db_connection
    return get_db_connection()


def _ensure_sync_failures_table(cursor):
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS sync_failures (
            id INT AUTO_INCREMENT PRIMARY KEY,
            target_module VARCHAR(20) NOT NULL,
            payload_json TEXT NOT NULL,
            reason VARCHAR(255) NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            resolved TINYINT(1) DEFAULT 0
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)


def _log_sync_failure(target_module: str, payload: dict, reason: str):
    try:
        conn = _get_voxify_db_connection()
        cursor = conn.cursor()
        _ensure_sync_failures_table(cursor)
        cursor.execute(
            "INSERT INTO sync_failures (target_module, payload_json, reason) VALUES (%s, %s, %s)",
            (target_module, json.dumps(payload), reason),
        )
        conn.commit()
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"[sync_failures] Could not log failure for {target_module}: {e}")


def sync_user_to_portal(username: str, password: str, full_name: str,
                         role: str, email: str = None,
                         external_id: str = None) -> dict:
    """
    Push a new user to the Portal so they can log in via SSO.

    role must be one of: 'superadmin', 'admin', 'teacher', 'student'
    (Voxify's 'voter' role has no Portal equivalent and maps to 'student' —
    see _portal_role() below).

    Returns a dict like:
        {"success": True,  "user_id": 5}
        {"success": False, "reason": "..."}

    Never raises — if the Portal is unreachable or rejects the request,
    the local module account still exists; this just means the person
    won't be able to log in via the Portal until synced.
    """
    payload = {
        "username":    username,
        "password":    password,
        "full_name":   full_name,
        "role":        role,
        "email":       email,
        "external_id": external_id,
    }
    try:
        resp = requests.post(CREATE_USER_ENDPOINT, json=payload, timeout=5)
        data = resp.json()
        if resp.status_code == 201:
            return {"success": True, "user_id": data.get("user_id")}
        return {"success": False, "reason": data.get("reason", "Unknown error")}
    except requests.exceptions.RequestException as e:
        return {"success": False, "reason": f"Portal unreachable: {e}"}


def _provision(endpoint: str, target_module: str, username: str, password: str,
               full_name: str, role: str, email: str = None) -> dict:
    """
    Shared helper for calling a module's /api/provision-user. Retries a
    few times first (covers the target app still booting); if it still
    fails, logs to `sync_failures` so it can be fixed later with one click
    via retry_failed_syncs() instead of a manual SQL insert.
    """
    payload = {
        "username":  username,
        "password":  password,
        "full_name": full_name,
        "role":      role,
        "email":     email,
    }
    last_reason = "Unknown error"
    for attempt in range(1, _RETRY_ATTEMPTS + 1):
        try:
            resp = requests.post(endpoint, json=payload, timeout=5, verify=False)
            data = resp.json()
            if resp.status_code == 201:
                return {"success": True}
            last_reason = data.get("reason", "Unknown error")
            break  # a real rejection won't be fixed by retrying
        except requests.exceptions.RequestException as e:
            last_reason = f"Unreachable: {e}"
            if attempt < _RETRY_ATTEMPTS:
                time.sleep(_RETRY_DELAY_S)

    _log_sync_failure(target_module, payload, last_reason)
    return {"success": False, "reason": last_reason}


def sync_user_to_testpoint(username: str, password: str, full_name: str,
                            role: str, email: str = None) -> dict:
    """
    Push a new user to TestPoint's local tables (users + teachers/students/
    admins) so they exist there too, using the same Portal-role spelling
    ('superadmin', not 'super_admin' — TestPoint's endpoint does that
    translation internally).
    """
    return _provision(TESTPOINT_PROVISION_URL, "testpoint", username, password, full_name, role, email)


def sync_user_to_attendance(username: str, password: str, full_name: str,
                             role: str, email: str = None) -> dict:
    """Push a new user to Attendance's local tables so they exist there too."""
    return _provision(ATTENDANCE_PROVISION_URL, "attendance", username, password, full_name, role, email)


def retry_failed_syncs() -> dict:
    """
    Re-attempt every unresolved row in `sync_failures`. Call this from an
    admin-triggered route ("Retry Failed Syncs" button) once the target
    module is confirmed running. Marks each row resolved on success.

    Returns: {"retried": N, "fixed": N, "still_failing": N, "reasons": [str, ...]}
    """
    conn = _get_voxify_db_connection()
    cursor = conn.cursor(dictionary=True)
    _ensure_sync_failures_table(cursor)
    cursor.execute("SELECT * FROM sync_failures WHERE resolved = 0")
    rows = cursor.fetchall()

    endpoints = {"testpoint": TESTPOINT_PROVISION_URL, "attendance": ATTENDANCE_PROVISION_URL}
    fixed = 0
    reasons = []
    for row in rows:
        payload = json.loads(row["payload_json"])
        endpoint = endpoints.get(row["target_module"])
        if not endpoint:
            continue
        try:
            resp = requests.post(endpoint, json=payload, timeout=5, verify=False)
            if resp.status_code == 201:
                cursor.execute("UPDATE sync_failures SET resolved = 1 WHERE id = %s", (row["id"],))
                conn.commit()
                fixed += 1
            else:
                data = resp.json()
                reason = data.get("reason", f"HTTP {resp.status_code}")
                reasons.append(f"{payload.get('username')} → {row['target_module']}: {reason}")
                cursor.execute("UPDATE sync_failures SET reason=%s WHERE id=%s", (reason, row["id"]))
                conn.commit()
        except requests.exceptions.RequestException as e:
            reason = f"Unreachable: {e}"
            reasons.append(f"{payload.get('username')} → {row['target_module']}: {reason}")
            cursor.execute("UPDATE sync_failures SET reason=%s WHERE id=%s", (reason, row["id"]))
            conn.commit()

    still_failing = len(rows) - fixed
    cursor.close()
    conn.close()
    return {"retried": len(rows), "fixed": fixed, "still_failing": still_failing, "reasons": reasons}


def portal_role(voxify_role: str) -> str:
    """
    Translate a Voxify role into a Portal role for syncing.
    Portal has no 'voter' concept — voters are just students there.
    """
    if voxify_role in ("superadmin", "admin"):
        return voxify_role
    return "student"