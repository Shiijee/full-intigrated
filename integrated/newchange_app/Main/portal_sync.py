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
import requests

PORTAL_URL      = os.getenv("PORTAL_URL",      "http://127.0.0.1:5000")
VOXIFY_URL      = os.getenv("VOXIFY_URL",       "http://127.0.0.1:5001")
TESTPOINT_URL   = os.getenv("TESTPOINT_URL",    "http://127.0.0.1:5003")

CREATE_USER_ENDPOINT     = f"{PORTAL_URL}/api/create-user"
VOXIFY_PROVISION_URL     = f"{VOXIFY_URL}/api/provision-user"
TESTPOINT_PROVISION_URL  = f"{TESTPOINT_URL}/api/provision-user"


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
    Mirror a newly-created Attendance user into Voxify and TestPoint,
    so the same Portal identity also has a working local profile in
    every module.

    Returns:
        {
            "voxify":    {"success": True/False, ...},
            "testpoint": {"success": True/False, ...},
        }

    Never raises — each module is tried independently.
    """
    return {
        "voxify":    _provision(VOXIFY_PROVISION_URL,    username, password, full_name, role, email),
        "testpoint": _provision(TESTPOINT_PROVISION_URL, username, password, full_name, role, email),
    }