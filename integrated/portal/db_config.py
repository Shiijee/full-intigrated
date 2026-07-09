import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv
import jwt

load_dotenv()
passwordDB = os.getenv("DBPASSWORD")

def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host = os.getenv('DB_HOST', 'localhost'),
            user='root',
            password=passwordDB,
            database='db_portal'
        )
        return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None
