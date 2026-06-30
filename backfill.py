"""
backfill_superadmin.py
=======================
One-time script to push the existing Voxify superadmin (SUPER001) into
TestPoint and Attendance, since that account was created before the
provision-user sync code existed and was never mirrored anywhere.

Run this once, from anywhere that can reach both servers, with both
TestPoint and Attendance already running:

    python backfill_superadmin.py

Safe to re-run: if the account already exists on either side, that
endpoint just returns a 409 and this script reports it without erroring.
"""

import os
import requests

TESTPOINT_URL  = os.getenv("TESTPOINT_URL", "http://127.0.0.1:5003")
ATTENDANCE_URL = os.getenv("ATTENDANCE_URL", "http://127.0.0.1:5002")

PAYLOAD = {
    "username":  "SUPER001",
    "password":  "Admin@123",          # plaintext — each side hashes it locally
    "full_name": "Super Nomo Admin",
    "role":      "superadmin",
    "email":     "jamesmatthewalmonte45@gmail.com",
}


def provision(label: str, base_url: str):
    url = f"{base_url}/api/provision-user"
    try:
        resp = requests.post(url, json=PAYLOAD, timeout=5)
        try:
            data = resp.json()
        except ValueError:
            print(f"[{label}] Non-JSON response (status {resp.status_code}). "
                  f"Body starts with: {resp.text[:200]!r}")
            return
        if resp.status_code == 201:
            print(f"[{label}] Success — SUPER001 now exists in {label}.")
        elif resp.status_code == 409:
            print(f"[{label}] Already exists — nothing to do. ({data.get('reason')})")
        else:
            print(f"[{label}] Failed ({resp.status_code}): {data.get('reason')}")
    except requests.exceptions.RequestException as e:
        print(f"[{label}] Unreachable: {e}")


if __name__ == "__main__":
    provision("TestPoint", TESTPOINT_URL)
    provision("Attendance", ATTENDANCE_URL)