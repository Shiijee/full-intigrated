"""
migrate_testpoint_to_portal.py
================================
ONE-TIME migration script.

Copies every existing account from db_exam.users (+ admins/teachers/students
profile tables for full names) into db_portal.users, so people who
registered in TestPoint BEFORE the SSO sync feature existed can now log
in via the Portal too.

Safe to run multiple times — skips usernames that already exist in
db_portal.users.

Skips any account whose password is not a real werkzeug hash (e.g. the
literal placeholder string "hashed_pass" seen in some seed/test rows) —
those can't log in anywhere as-is and would be misleading to migrate.

Run from anywhere with:
    python migrate_testpoint_to_portal.py

Requires: mysql-connector-python  (pip install mysql-connector-python --break-system-packages)
"""

import mysql.connector


def get_connection(database: str):
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="",
        database=database,
    )


def map_role(testpoint_role: str) -> str:
    """
    TestPoint roles: super_admin | admin | teacher | student
    Portal roles:    superadmin  | admin | teacher | student
    Only the superadmin spelling differs.
    """
    if testpoint_role == "super_admin":
        return "superadmin"
    return testpoint_role


def looks_like_real_hash(password: str) -> bool:
    """
    Real werkzeug hashes start with a known prefix like 'scrypt:' or
    'pbkdf2:'. Placeholder/seed data (e.g. the literal string
    'hashed_pass') won't match and gets skipped.
    """
    if not password:
        return False
    return password.startswith(("scrypt:", "pbkdf2:"))


def get_full_name(cursor, role: str, user_id: str) -> str | None:
    """Look up firstname/middlename/lastname from the role-specific profile table."""
    table = {"admin": "admins", "super_admin": "admins",
             "teacher": "teachers", "student": "students"}.get(role)
    if not table:
        return None

    id_column = {"admins": "admin_id", "teachers": "teacher_id", "students": "student_id"}[table]

    cursor.execute(
        f"SELECT firstname, middlename, lastname FROM {table} WHERE {id_column} = %s",
        (user_id,),
    )
    row = cursor.fetchone()
    if not row:
        return None

    parts = [row["firstname"]]
    if row.get("middlename"):
        parts.append(row["middlename"])
    parts.append(row["lastname"])
    return " ".join(p for p in parts if p)


def main():
    print("Connecting to db_exam...")
    tp_conn = get_connection("db_exam")
    tp_cursor = tp_conn.cursor(dictionary=True)

    print("Connecting to db_portal...")
    portal_conn = get_connection("db_portal")
    portal_cursor = portal_conn.cursor(dictionary=True)

    print("Fetching existing TestPoint users...\n")
    tp_cursor.execute("SELECT user_id, email, password, role FROM users")
    tp_users = tp_cursor.fetchall()
    print(f"Found {len(tp_users)} TestPoint accounts.\n")

    # Separate cursor for profile-table lookups, since the main cursor
    # is still iterating over the outer result set.
    profile_cursor = tp_conn.cursor(dictionary=True)

    created = 0
    skipped_existing = 0
    skipped_bad_hash = 0
    skipped_no_profile = 0

    for u in tp_users:
        username = (u["user_id"] or "").strip()
        role = u["role"]

        if not looks_like_real_hash(u["password"]):
            print(f"  SKIP — '{username}' has a placeholder/invalid password hash")
            skipped_bad_hash += 1
            continue

        full_name = get_full_name(profile_cursor, role, username)
        if not full_name:
            print(f"  SKIP — '{username}' has no matching profile row (no name found)")
            skipped_no_profile += 1
            continue

        portal_role = map_role(role)

        portal_cursor.execute("SELECT id FROM users WHERE username = %s", (username,))
        if portal_cursor.fetchone():
            print(f"  SKIP — '{username}' already exists in Portal")
            skipped_existing += 1
            continue

        portal_cursor.execute(
            "INSERT INTO users (username, password, full_name, email, role, external_id) "
            "VALUES (%s, %s, %s, %s, %s, %s)",
            (username, u["password"], full_name, u["email"], portal_role, username),
        )
        portal_conn.commit()
        created += 1
        print(f"  CREATED — '{username}' ({full_name}) as Portal role '{portal_role}'")

    print("\n── Migration summary ──────────────────────")
    print(f"  Created:              {created}")
    print(f"  Skipped (exists):     {skipped_existing}")
    print(f"  Skipped (bad hash):   {skipped_bad_hash}")
    print(f"  Skipped (no profile): {skipped_no_profile}")
    print(f"  Total processed:      {len(tp_users)}")

    tp_cursor.close()
    profile_cursor.close()
    tp_conn.close()
    portal_cursor.close()
    portal_conn.close()


if __name__ == "__main__":
    main()