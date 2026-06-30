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
import requests

PORTAL_URL          = os.getenv("PORTAL_URL", "http://127.0.0.1:5000")
CREATE_USER_ENDPOINT = f"{PORTAL_URL}/api/create-user"


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


def portal_role(voxify_role: str) -> str:
    """
    Translate a Voxify role into a Portal role for syncing.
    Portal has no 'voter' concept — voters are just students there.
    """
    if voxify_role in ("superadmin", "admin"):
        return voxify_role
    return "student"