import mysql.connector
import os
from dotenv import load_dotenv

load_dotenv()


def get_db_connection():
    try:
        conn = mysql.connector.connect(
            host=os.getenv("DB_HOST", "127.0.0.1"),
            database=os.getenv("DB_NAME", "db_attendance"),
            user=os.getenv("DB_USER", "root"),
            password=os.getenv("DB_PASSWORD", ""),
            port=int(os.getenv("DB_PORT", 3306)),
            charset="utf8mb4",
            collation="utf8mb4_unicode_ci",
            autocommit=False,
        )
        return conn
    except Exception as err:
        print(f"Error connecting to DB: {err}")
        return None


def get_cursor(conn):
    """Returns a dictionary cursor."""
    return conn.cursor(dictionary=True)


def log_system_action(
    cursor,
    table_name,
    entity_id,
    action,
    performed_by_id,
    performed_by_role,
    details="",
):
    """Logs an action into the system_audit_log table."""
    try:
        cursor.execute(
            """
            INSERT INTO system_audit_log (table_name, entity_id, action, performed_by_id, performed_by_role, details)
            VALUES (%s, %s, %s, %s, %s, %s)
        """,
            (
                table_name,
                str(entity_id),
                action,
                str(performed_by_id),
                performed_by_role,
                details,
            ),
        )
    except Exception as e:
        print(f"Audit log error: {e}")
