"""
newchange_app/Main/portal_sync.py
==================================
Helper that pushes newly-created users in Attendance (NewChange) to:
  1. The Portal's unified users table (so they can log in via SSO)
  2. Voxify's /api/provision-user (so they get a local voter/admin row)
  3. TestPoint's /api/provision-user (so they get a local student/teacher/admin row)

Call this right after a successful local insert, using the PLAINTEXT
password (Portal and each module hash on their own end).
"""

import os
import json
import time
import requests
from Main.db import get_db_connection

PORTAL_URL      = os.getenv("PORTAL_URL",      "http://127.0.0.1:5000")
VOXIFY_URL      = os.getenv("VOXIFY_URL",       "http://127.0.0.1:5001")
TESTPOINT_URL   = os.getenv("TESTPOINT_URL",    "http://127.0.0.1:5003")

CREATE_USER_ENDPOINT     = f"{PORTAL_URL}/api/create-user"
VOXIFY_PROVISION_URL     = f"{VOXIFY_URL}/api/provision-user"
TESTPOINT_PROVISION_URL  = f"{TESTPOINT_URL}/api/provision-user"

_RETRY_ATTEMPTS = 3
_RETRY_DELAY_S  = 2


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
        conn = get_db_connection()
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
    few times first (covers the target app still booting); logs to
    `sync_failures` if it still fails, so it can be replayed later with
    retry_failed_syncs() instead of a manual fix.
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
            resp = requests.post(endpoint, json=payload, timeout=5)
            data = resp.json()
            if resp.status_code == 201:
                return {"success": True}
            last_reason = data.get("reason", "Unknown error")
            break
        except requests.exceptions.RequestException as e:
            last_reason = f"Unreachable: {e}"
            if attempt < _RETRY_ATTEMPTS:
                time.sleep(_RETRY_DELAY_S)

    _log_sync_failure(target_module, payload, last_reason)
    return {"success": False, "reason": last_reason}


def mirror_user_to_modules(username: str, password: str, full_name: str,
                            role: str, email: str = None) -> dict:
    """
    Mirror a newly-created Attendance user into Voxify and TestPoint,
    so the same Portal identity also has a working local profile in
    every module.

    Voxify has no 'teacher' concept — mirroring a teacher there is
    permanently rejected by design, so skip that call entirely for
    teachers instead of logging an unfixable "failure" every time.

    Returns:
        {
            "voxify":    {"success": True/False, ...},   # omitted for teachers
            "testpoint": {"success": True/False, ...},
        }

    Never raises — each module is tried independently.
    """
    results = {
        "testpoint": _provision(TESTPOINT_PROVISION_URL, "testpoint", username, password, full_name, role, email),
    }
    if role != "teacher":
        results["voxify"] = _provision(VOXIFY_PROVISION_URL, "voxify", username, password, full_name, role, email)
    return results


def retry_failed_syncs() -> dict:
    """Re-attempt every unresolved row in `sync_failures`. See TestPoint/
    Voxify's identical helper for the full explanation."""
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    _ensure_sync_failures_table(cursor)
    cursor.execute("SELECT * FROM sync_failures WHERE resolved = 0")
    rows = cursor.fetchall()

    endpoints = {"voxify": VOXIFY_PROVISION_URL, "testpoint": TESTPOINT_PROVISION_URL}
    fixed = 0
    reasons = []
    for row in rows:
        payload = json.loads(row["payload_json"])
        endpoint = endpoints.get(row["target_module"])
        if not endpoint:
            continue
        try:
            resp = requests.post(endpoint, json=payload, timeout=5)
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