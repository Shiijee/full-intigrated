import mysql.connector
from mysql.connector.cursor import MySQLCursorDict
import os
from dotenv import load_dotenv

load_dotenv()

def get_db_connection():
    try:
        conn = mysql.connector.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            database=os.getenv('DB_NAME', 'attendeez'),
            user=os.getenv('DB_USER', 'root'),
            password=os.getenv('DB_PASSWORD', ''),
            port=int(os.getenv('DB_PORT', '3306')),
            auth_plugin='mysql_native_password'
        )
        return conn
    except Exception as err:
        print(f"Error connecting to DB: {err}")
        return None

def log_system_action(cursor, table_name, entity_id, action, performed_by_id, performed_by_role, details=None):
    try:
        cursor.execute("""
            INSERT INTO System_Audit_Log (table_name, entity_id, action, performed_by_id, performed_by_role, details)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (table_name, str(entity_id), action, str(performed_by_id), performed_by_role, details))
    except Exception as e:
        print(f"Failed to log system action: {e}")