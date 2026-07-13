# Attendance Management System

✅ **MIGRATED TO MYSQL** - Now using MySQL/MariaDB instead of PostgreSQL

## Quick Start

### 1. Start XAMPP MySQL

Open XAMPP Control Panel → Start MySQL

### 2. Run the App

```bash
cd C:\NewChangeRepo
python app.py
```

### 3. Access the App

**From your computer:**

```
http://127.0.0.1:5000
```

**From your phone (same WiFi):**

```
http://YOUR-IP-ADDRESS:5000
```

**Find your IP:** Run `find_my_ip.bat` or type `ipconfig` in command prompt

---

## Default Login Credentials

### Admin Account

- **Username:** `admin1`
- **Password:** `password123`
- **Email:** `adminattendeez0218@gmail.com`

### Teacher Account (Test Data)

- **Username:** `T26-0001`
- **Password:** `password123`
- **Email:** `maria.reyes@gmail.com`

### Student Account (Test Data)

- **Username:** `S26-0001`
- **Password:** `password123`
- **Email:** `juan.delacruz@gmail.com`

---

## Setup Instructions

### First Time Setup

1. **Install Dependencies**

```bash
pip install -r requirements.txt
```

2. **Initialize Database** (if not already done)

```bash
python init_db.py
```

3. **Import Database** (alternative)

- Open phpMyAdmin: http://localhost/phpmyadmin
- Import `database.sql`
- Import `triggers.sql` (optional)

### Configuration

Database settings are in `.env`:

```
DB_HOST=127.0.0.1
DB_USER=root
DB_PASSWORD=
DB_NAME=db_attendance
DB_PORT=3306
```
  
---

## Phone Access Setup

### For Testing with Teacher on Same WiFi

1. **Find Your Computer's IP**
   - Run: `find_my_ip.bat`
   - Or: `ipconfig` and look for IPv4 Address

2. **Connect Both Devices to Same WiFi**
   - Your computer and teacher's phone must be on the same network

3. **Share the URL**
   - Give teacher: `http://YOUR-IP:5000`
   - Example: `http://192.168.1.100:5000`

4. **Start the App**
   ```bash
   python app.py
   ```

**See `NETWORK_SETUP_GUIDE.md` for detailed instructions**

---

## Testing

Test database connection:

```bash
python test_mysql_connection.py
```

Should show:

```
✓ Connection successful!
✓ MySQL/MariaDB version: 8.4.3
✓ Found 17 tables in database
✓ Admin user found
```

---

## Features

- 📱 **QR Code Attendance** - Scan to mark attendance
- 👨‍🏫 **Teacher Dashboard** - Manage classes and attendance
- 👨‍🎓 **Student Portal** - View attendance and submit excuses
- 📊 **Analytics** - Attendance reports and statistics
- 📝 **Excuse Letters** - Submit and review excuses
- 🔐 **Security** - Role-based access control
- 📍 **Location Verification** - GPS-based attendance validation
- 🔔 **Notifications** - Real-time updates

---

## Project Structure

```
Main/
├── admin/          # Admin panel and CRUD operations
├── auth/           # Login, logout, password management
├── student/        # Student dashboard and features
├── teacher/        # Teacher dashboard and attendance
└── db.py          # MySQL database connection

database.sql       # Database schema (MySQL)
triggers.sql       # Database triggers
app.py            # Main Flask application
.env              # Configuration (database, SMTP, etc.)
```

---

## Documentation

- 📄 **MIGRATION_COMPLETE.md** - Details about PostgreSQL → MySQL migration
- 📄 **NETWORK_SETUP_GUIDE.md** - Complete guide for phone access setup
- 📄 **database.sql** - MySQL database schema
- 📄 **triggers.sql** - MySQL triggers

---

## Tech Stack

- **Backend:** Flask 3.1.3
- **Database:** MySQL 8.x / MariaDB 10.x
- **Frontend:** HTML5, CSS3, JavaScript
- **Authentication:** Flask sessions + Werkzeug security
- **QR Codes:** Python qrcode library
- **Email:** SMTP (Gmail)

---

## Troubleshooting

### Database Connection Failed

- ✅ XAMPP MySQL is running?
- ✅ Database `db_attendance` exists?
- ✅ Check credentials in `.env`

### Phone Can't Access

- ✅ Both on SAME WiFi network?
- ✅ Using correct IP address?
- ✅ App is running on computer?
- ✅ Windows Firewall allows port 5000?

### Collation Error

- ✅ Already fixed! All tables use `utf8mb4_unicode_ci`
- If still occurs, reimport `database.sql`

**For more help, see `NETWORK_SETUP_GUIDE.md`**

---

## What's New (Recent Changes)

### ✅ PostgreSQL → MySQL Migration

- Switched from Supabase PostgreSQL to local MySQL
- Fixed collation errors (all tables now utf8mb4_unicode_ci)
- Updated all database code to use mysql.connector
- Removed PostgreSQL dependencies

### ✅ Network Access Enabled

- Flask now runs on `0.0.0.0` (all interfaces)
- Phones can access from same WiFi
- Added `find_my_ip.bat` helper script

### ✅ Code Cleanup

- Removed all Supabase/PostgreSQL code
- Updated requirements.txt
- Fixed table name casing (lowercase)

---

## Support

📧 **Email:** adminattendeez0218@gmail.com

📚 **Documentation:**

- Quick start: This README
- Phone setup: `NETWORK_SETUP_GUIDE.md`
- Migration info: `MIGRATION_COMPLETE.md`

---

## License

[Your License Here]
