"""
testpoint_app/testpoint/portal_sync.py
========================================
Helper that pushes newly-created users to the Portal's unified
`users` table, so they can immediately log in via SSO across
all modules.

Call this right after a module successfully creates a local user,
using the PLAINTEXT password (the Portal hashes it on arrival —
see portal/app.py's /api/create-user).
"""

import os
import json
import time
import requests
import urllib3
import mysql.connector
from testpoint import db_config

# NewChange serves HTTPS using a self-signed cert (cert.pem/key.pem) — verify=False
# is needed below or every request to it raises SSLCertVerificationError. Suppress
# the accompanying "InsecureRequestWarning" since we already know it's self-signed.
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

PORTAL_URL          = os.getenv("PORTAL_URL",     "http://127.0.0.1:5000")
VOXIFY_URL          = os.getenv("VOXIFY_URL",      "http://127.0.0.1:5001")
ATTENDANCE_URL      = os.getenv("ATTENDANCE_URL",  "https://127.0.0.1:5002")

CREATE_USER_ENDPOINT     = f"{PORTAL_URL}/api/create-user"
VOXIFY_PROVISION_URL     = f"{VOXIFY_URL}/api/provision-user"
ATTENDANCE_PROVISION_URL = f"{ATTENDANCE_URL}/api/provision-user"

_RETRY_ATTEMPTS = 3
_RETRY_DELAY_S  = 2  # seconds between attempts — covers "the other app is still booting"


def _ensure_sync_failures_table(cursor):
    """Created on first use — no migration step needed for the project."""
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
    """Best-effort — if even logging fails, we just print, we don't crash
    the account-creation flow over it."""
    try:
        conn = mysql.connector.connect(**db_config)
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
    Shared helper for calling a module's /api/provision-user.

    Retries a few times with a short delay first — this alone fixes the
    common case where the target app was just slow to start. If it still
    fails after all attempts (app genuinely down, or a real rejection like
    a duplicate ID), the failure is logged to `sync_failures` instead of
    just being printed, so it can be retried later with one click via
    retry_failed_syncs() instead of a manual SQL fix.
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
            # A real rejection (e.g. duplicate ID) won't be fixed by retrying —
            # log it immediately instead of burning the remaining attempts.
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
    Mirror a newly-created TestPoint user into Voxify and Attendance.

    Voxify has no 'teacher' concept (it's an e-voting system: only
    superadmin/admin/voter exist there) — mirroring a teacher to Voxify is
    permanently rejected by design, not a transient failure. Skip that
    call entirely for teachers so it never clutters sync_failures with an
    entry that can never succeed no matter how many times it's retried.

    Returns:
        {
            "voxify":    {"success": True/False, ...},   # omitted for teachers
            "attendance": {"success": True/False, ...},
        }

    Never raises — each module is tried independently. Any failure that
    survives the retries is logged to `sync_failures` for later replay.
    """
    results = {
        "attendance": _provision(ATTENDANCE_PROVISION_URL, "attendance", username, password, full_name, role, email),
    }
    if role != "teacher":
        results["voxify"] = _provision(VOXIFY_PROVISION_URL, "voxify", username, password, full_name, role, email)
    return results


def retry_failed_syncs() -> dict:
    """
    Re-attempt every unresolved row in `sync_failures`. Call this from an
    admin-triggered route ("Retry Failed Syncs" button) once you're sure
    the target module is up. Marks each row resolved on success.

    Returns: {"retried": N, "fixed": N, "still_failing": N, "reasons": [str, ...]}
    """
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor(dictionary=True)
    _ensure_sync_failures_table(cursor)
    cursor.execute("SELECT * FROM sync_failures WHERE resolved = 0")
    rows = cursor.fetchall()

    endpoints = {"voxify": VOXIFY_PROVISION_URL, "attendance": ATTENDANCE_PROVISION_URL}
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


def portal_role(testpoint_role: str) -> str:
    """
    Translate a TestPoint role into a Portal role for syncing.
    Only the superadmin spelling differs (underscore vs none).
    """
    if testpoint_role == "super_admin":
        return "superadmin"
    return testpoint_role