import mysql.connector
import os
from dotenv import load_dotenv
from werkzeug.security import generate_password_hash

load_dotenv()


def init_db():
    try:
        # First connect without specifying a database to create it if needed
        conn = mysql.connector.connect(
            host=os.getenv("DB_HOST", "127.0.0.1"),
            user=os.getenv("DB_USER", "root"),
            password=os.getenv("DB_PASSWORD", ""),
            port=int(os.getenv("DB_PORT", 3306)),
        )
        cursor = conn.cursor()
        db_name = os.getenv("DB_NAME", "db_attendance")
        cursor.execute(
            f"CREATE DATABASE IF NOT EXISTS `{db_name}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
        )
        cursor.execute(f"USE `{db_name}`")
        conn.commit()

        # Read and execute the SQL schema file
        with open("database.sql", "r") as f:
            sql_script = f.read()

        print("Executing database.sql...")

        # Split by DELIMITER blocks and semicolons carefully
        statements = []
        current = []
        in_delimiter_block = False

        for line in sql_script.splitlines():
            stripped = line.strip()
            if stripped.upper().startswith("DELIMITER"):
                if "$" in stripped:
                    in_delimiter_block = True
                else:
                    in_delimiter_block = False
                continue

            if in_delimiter_block:
                if stripped == "$":
                    stmt = "\n".join(current).strip()
                    if stmt:
                        statements.append(stmt)
                    current = []
                else:
                    current.append(line)
            else:
                current.append(line)
                joined = "\n".join(current).strip()
                if joined.endswith(";"):
                    statements.append(joined)
                    current = []

        for stmt in statements:
            stmt = stmt.strip().rstrip(";")
            if stmt:
                try:
                    cursor.execute(stmt)
                    conn.commit()
                except mysql.connector.Error as e:
                    if e.errno in (1050, 1304, 1360):  # Table/trigger already exists
                        pass
                    else:
                        print(f"Warning executing statement: {e}")
                        print(f"Statement: {stmt[:100]}...")

        # Insert/Update the admin user
        admin_user = "admin1"
        admin_pass = "password123"
        admin_email = "adminattendeez0218@gmail.com"
        hashed_pass = generate_password_hash(admin_pass)

        print(f"Ensuring admin user '{admin_user}' exists...")
        cursor.execute(
            """
            INSERT INTO admins (username, password_hash, email)
            VALUES (%s, %s, %s)
            ON DUPLICATE KEY UPDATE password_hash = VALUES(password_hash)
        """,
            (admin_user, hashed_pass, admin_email),
        )
        conn.commit()

        print("Database initialized successfully!")
        print(f"  Host:     {os.getenv('DB_HOST', '127.0.0.1')}")
        print(f"  Database: {db_name}")
        print(f"  Admin:    {admin_user} / password123")
        print()
        print("NOTE: To set up triggers, run triggers.sql separately in phpMyAdmin.")

        cursor.close()
        conn.close()

    except Exception as e:
        print(f"Error initializing database: {e}")


if __name__ == "__main__":
    init_db()
