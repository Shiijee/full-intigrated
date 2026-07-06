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
import requests

PORTAL_URL          = os.getenv("PORTAL_URL",     "http://127.0.0.1:5000")
VOXIFY_URL          = os.getenv("VOXIFY_URL",      "http://127.0.0.1:5001")
ATTENDANCE_URL      = os.getenv("ATTENDANCE_URL",  "http://127.0.0.1:5002")

CREATE_USER_ENDPOINT     = f"{PORTAL_URL}/api/create-user"
VOXIFY_PROVISION_URL     = f"{VOXIFY_URL}/api/provision-user"
ATTENDANCE_PROVISION_URL = f"{ATTENDANCE_URL}/api/provision-user"


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


def _provision(endpoint: str, username: str, password: str,
               full_name: str, role: str, email: str = None) -> dict:
    """Shared helper for calling a module's /api/provision-user."""
    payload = {
        "username":  username,
        "password":  password,
        "full_name": full_name,
        "role":      role,
        "email":     email,
    }
    try:
        resp = requests.post(endpoint, json=payload, timeout=5)
        data = resp.json()
        if resp.status_code == 201:
            return {"success": True}
        return {"success": False, "reason": data.get("reason", "Unknown error")}
    except requests.exceptions.RequestException as e:
        return {"success": False, "reason": f"Unreachable: {e}"}


def mirror_user_to_modules(username: str, password: str, full_name: str,
                            role: str, email: str = None) -> dict:
    """
    Mirror a newly-created TestPoint user into Voxify and Attendance.

    Returns:
        {
            "voxify":    {"success": True/False, ...},
            "attendance": {"success": True/False, ...},
        }

    Never raises — each module is tried independently.
    """
    return {
        "voxify":     _provision(VOXIFY_PROVISION_URL,     username, password, full_name, role, email),
        "attendance": _provision(ATTENDANCE_PROVISION_URL, username, password, full_name, role, email),
    }


def portal_role(testpoint_role: str) -> str:
    """
    Translate a TestPoint role into a Portal role for syncing.
    Only the superadmin spelling differs (underscore vs none).
    """
    if testpoint_role == "super_admin":
        return "superadmin"
    return testpoint_role