from flask import Blueprint, render_template, request, session, redirect, url_for, flash
from werkzeug.security import check_password_hash, generate_password_hash
from Main.db import get_db_connection, get_cursor
from datetime import datetime, timedelta
import secrets
import smtplib
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def generate_otp():
    return str(secrets.randbelow(9000) + 1000)

def send_otp_email(receiver_email, otp, unique_id=''):
    smtp_server  = os.getenv("SMTP_SERVER", "smtp.gmail.com")
    smtp_port    = int(os.getenv("SMTP_PORT", 587))
    smtp_user    = os.getenv("SMTP_USER", "").strip()
    smtp_password = os.getenv("SMTP_PASSWORD", "").strip()

    if not smtp_user or not smtp_password or "your-email" in smtp_user:
        print("CRITICAL: SMTP credentials not configured in .env file.")
        return False

    msg = MIMEMultipart()
    msg['From']    = f"Attendeez Support <{smtp_user}>"
    msg['To']      = receiver_email
    msg['Subject'] = f"{otp} is your Attendeez Reset Code"

    uid_section = ''
    if unique_id:
        uid_section = f"""
            <div style="text-align:center;margin:20px 0;padding:15px;background:#eef4ff;
                        border-radius:8px;border:1px dashed #4A90E2;">
                <p style="margin:0 0 6px 0;font-size:13px;color:#555;">Your Unique System ID</p>
                <span style="font-size:22px;font-weight:bold;letter-spacing:3px;color:#4A90E2;">{unique_id}</span>
                <p style="margin:6px 0 0 0;font-size:12px;color:#888;">Use this ID to log in to the system.</p>
            </div>
        """

    body = f"""
    <html><body style="font-family:Arial,sans-serif;line-height:1.6;color:#333;">
        <div style="max-width:600px;margin:0 auto;padding:20px;border:1px solid #ddd;border-radius:10px;">
            <h2 style="color:#4A90E2;text-align:center;">Password Reset Request</h2>
            <p>Hello,</p>
            <p>You requested to reset your password. Use the following OTP code to proceed:</p>
            <div style="text-align:center;margin:30px 0;">
                <span style="font-size:32px;font-weight:bold;letter-spacing:5px;background:#f4f4f4;
                             padding:10px 20px;border-radius:5px;border:1px dashed #4A90E2;">{otp}</span>
            </div>
            {uid_section}
            <p>This code will expire in 10 minutes. If you did not request this, please ignore this email.</p>
            <hr style="border:none;border-top:1px solid #eee;">
            <p style="font-size:12px;color:#888;text-align:center;">&copy; 2024 Attendeez Attendance System</p>
        </div>
    </body></html>
    """
    msg.attach(MIMEText(body, 'html'))

    try:
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()
        server.login(smtp_user, smtp_password)
        server.send_message(msg)
        server.quit()
        return True
    except Exception as e:
        print(f"SMTP Error: {e}")
        return False

# ---------------------------------------------------------------------------
# Role helper — derive role from user_id prefix
# ---------------------------------------------------------------------------
def get_role_from_user_id(user_id: str) -> str:
    """
    Returns 'student' if user_id starts with 'S',
            'teacher' if user_id starts with 'T',
            'unknown' otherwise.
    """
    if not user_id:
        return 'unknown'
    prefix = user_id[0].upper()
    if prefix == 'S':
        return 'student'
    if prefix == 'T':
        return 'teacher'
    return 'unknown'

# ---------------------------------------------------------------------------
# OTP Rate-Limit / Lockout Helpers
# ---------------------------------------------------------------------------
OTP_MAX_SENDS     = 5
OTP_COOLDOWN_SECS = 120
OTP_MAX_WRONG     = 5
OTP_LOCKOUT_HOURS = 12

def _get_otp_lockout(cursor, email):
    try:
        cursor.execute("SELECT lockout_until FROM otp_lockouts WHERE email = %s", (email,))
        row = cursor.fetchone()
        if row:
            lu = row['lockout_until']
            if isinstance(lu, datetime) and lu > datetime.now():
                return lu
            cursor.execute("DELETE FROM otp_lockouts WHERE email = %s", (email,))
    except Exception:
        pass
    return None

def _set_otp_lockout(conn, cursor, email):
    until = datetime.now() + timedelta(hours=OTP_LOCKOUT_HOURS)
    cursor.execute("""
        INSERT INTO otp_lockouts (email, lockout_until)
        VALUES (%s, %s)
        ON DUPLICATE KEY UPDATE lockout_until = VALUES(lockout_until)
    """, (email, until))
    conn.commit()
    for k in ('reset_otp', 'reset_email', 'reset_unique_id', 'reset_type',
              'otp_expiry', 'otp_send_count', 'otp_last_sent', 'otp_wrong_count'):
        session.pop(k, None)
    return until

def _clear_otp_session():
    for k in ('reset_otp', 'reset_email', 'reset_unique_id', 'reset_type',
              'otp_expiry', 'otp_verified', 'otp_send_count',
              'otp_last_sent', 'otp_wrong_count'):
        session.pop(k, None)

# ---------------------------------------------------------------------------
auth = Blueprint('auth', __name__, template_folder='templates')

@auth.after_request
def add_header(response):
    response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0, max-age=0'
    response.headers['Pragma']  = 'no-cache'
    response.headers['Expires'] = '-1'
    return response

# ---------------------------------------------------------------------------
# /login  — redirect based on session role
# ---------------------------------------------------------------------------
@auth.route('/login')
def login_redirect():
    if 'user_id' in session:
        role = session.get('role')
        if role == 'student': return redirect(url_for('user.dashboard'))
        if role == 'teacher': return redirect(url_for('teacher.dashboard'))
        if role == 'admin':   return redirect(url_for('admin.dashboard'))
    return redirect(url_for('auth.login'))          # fall through to unified login

# ---------------------------------------------------------------------------
# UNIFIED LOGIN  (students & teachers share one page)
# The prefix of the user_id determines the role:
#   S26-xxxx → student   (lookup in Students table)
#   T26-xxxx → teacher   (lookup in Teachers table)
# ---------------------------------------------------------------------------
@auth.route('/user/login', methods=['GET', 'POST'])
def student_login():
    """
    Unified login for students (S26-xxxx) and teachers (T26-xxxx).
    The user_id prefix decides which table to query and which dashboard to land on.
    Kept as 'student_login' for backward-compat with url_for('auth.student_login').
    """
    if 'user_id' in session:
        role = session.get('role')
        if role == 'student': return redirect(url_for('user.dashboard'))
        if role == 'teacher': return redirect(url_for('teacher.dashboard'))
        if role == 'admin':   return redirect(url_for('admin.dashboard'))

    if request.method == 'POST':
        uid_input = (request.form.get('user_id') or '').strip()
        password  = request.form.get('password', '')

        if not uid_input:
            flash('Please enter your User ID.', 'error')
            return render_template('student_login.html', prefill_id=uid_input)

        detected_role = get_role_from_user_id(uid_input)

        conn = get_db_connection()
        if not conn:
            flash('Database connection failed.', 'error')
            return render_template('student_login.html', prefill_id=uid_input)

        cursor = get_cursor(conn)

        if detected_role == 'student':
            cursor.execute("SELECT * FROM Students WHERE user_id = %s", (uid_input,))
            user = cursor.fetchone()
            table   = 'Students'
            dest_fn = lambda: redirect(url_for('user.dashboard'))
            role_str = 'student'

        elif detected_role == 'teacher':
            cursor.execute("SELECT * FROM Teachers WHERE user_id = %s", (uid_input,))
            user = cursor.fetchone()
            table   = 'Teachers'
            dest_fn = lambda: redirect(url_for('teacher.dashboard'))
            role_str = 'teacher'

        else:
            cursor.close()
            conn.close()
            flash('Invalid User ID format. IDs start with S (student) or T (teacher).', 'error')
            return render_template('student_login.html', prefill_id=uid_input)

        if user:
            # Check user_role column matches expected role (DB-level integrity check)
            if user.get('user_role') != role_str:
                cursor.close()
                conn.close()
                flash('Account role mismatch. Please contact admin.', 'error')
                return render_template('student_login.html', prefill_id=uid_input)

            if user.get('status') == 'Archived':
                flash('Account is disabled. Please contact admin.', 'error')
            elif user.get('lockout_time') and user['lockout_time'] > datetime.now():
                flash(f'Account locked. Try again after {user["lockout_time"].strftime("%Y-%m-%d %H:%M")}', 'error')
            elif user['password_hash'] and check_password_hash(user['password_hash'], password):
                cursor.execute(
                    f"UPDATE {table} SET failed_attempts = 0, lockout_time = NULL WHERE user_id = %s",
                    (user['user_id'],)
                )
                cursor.execute(
                    "INSERT INTO login_logs (user_id, user_role, login_time) VALUES (%s, %s, NOW())",
                    (user['user_id'], role_str)
                )
                conn.commit()
                log_id = cursor.lastrowid
                session['login_log_id'] = log_id
                session.permanent = True
                session['user_id']   = user['user_id']
                session['role']      = role_str
                session['user_role'] = role_str        # redundant but explicit
                session['name']      = f"{user['first_name']} {user['middle_name']} {user['last_name']}"
                cursor.close()
                conn.close()
                return dest_fn()
            else:
                attempts = (user.get('failed_attempts') or 0) + 1
                lockout  = None
                if attempts >= 10:
                    lockout = datetime.now() + timedelta(hours=2)
                    flash('Account locked for 2 hours due to 10 failed attempts. Contact admin to unlock.', 'error')
                else:
                    flash(f'Invalid credentials. {10 - attempts} attempts remaining.', 'error')
                cursor.execute(
                    f"UPDATE {table} SET failed_attempts = %s, lockout_time = %s WHERE user_id = %s",
                    (attempts, lockout, user['user_id'])
                )
                conn.commit()
        else:
            flash(f'User ID not found.', 'error')

        cursor.close()
        conn.close()
        return render_template('student_login.html', prefill_id=uid_input)

    return render_template('student_login.html')


# Keep old /student/login and /teacher/login routes pointing to the unified login
@auth.route('/student/login', methods=['GET', 'POST'])
def student_login_legacy():
    return student_login()

# teacher/login is now handled by the teacher blueprint directly at /teacher/login


# ---------------------------------------------------------------------------
# ADMIN LOGIN  (separate — uses username, not user_id)
# ---------------------------------------------------------------------------
@auth.route('/admin/login', methods=['GET', 'POST'])
def admin_login():
    if 'user_id' in session:
        role = session.get('role')
        if role == 'student': return redirect(url_for('user.dashboard'))
        if role == 'teacher': return redirect(url_for('teacher.dashboard'))
        if role == 'admin':   return redirect(url_for('admin.dashboard'))

    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '')

        conn = get_db_connection()
        if not conn:
            flash('Database connection failed.', 'error')
            return render_template('admin_login.html')

        cursor = get_cursor(conn)
        cursor.execute("SELECT * FROM Admins WHERE username = %s", (username,))
        admin = cursor.fetchone()

        if admin:
            if admin['lockout_time'] and admin['lockout_time'] > datetime.now():
                flash(f'Account locked. Try again after {admin["lockout_time"].strftime("%Y-%m-%d %H:%M")}', 'error')
            elif admin['password_hash'] and check_password_hash(admin['password_hash'], password):
                cursor.execute(
                    "UPDATE Admins SET failed_attempts = 0, lockout_time = NULL WHERE admin_id = %s",
                    (admin['admin_id'],)
                )
                cursor.execute(
                    "INSERT INTO login_logs (user_id, user_role, login_time) VALUES (%s, 'admin', NOW())",
                    (str(admin['admin_id']),)
                )
                conn.commit()
                log_id = cursor.lastrowid
                session['login_log_id'] = log_id
                session.permanent = True
                session['user_id']   = admin['admin_id']
                session['role']      = 'admin'
                session['user_role'] = 'admin'
                cursor.close()
                conn.close()
                return redirect(url_for('admin.dashboard'))
            else:
                attempts = (admin.get('failed_attempts') or 0) + 1
                lockout  = None
                if attempts >= 5:
                    lockout = datetime.now() + timedelta(hours=2)
                    flash('Account locked for 2 hours due to 5 failed attempts.', 'error')
                else:
                    flash(f'Invalid credentials. {5 - attempts} attempts remaining.', 'error')
                cursor.execute(
                    "UPDATE Admins SET failed_attempts = %s, lockout_time = %s WHERE admin_id = %s",
                    (attempts, lockout, admin['admin_id'])
                )
                conn.commit()
        else:
            flash('Invalid credentials.', 'error')

        cursor.close()
        conn.close()
        return render_template('admin_login.html', prefill_id=username)

    return render_template('admin_login.html')


# ---------------------------------------------------------------------------
# FORGOT PASSWORD
# ---------------------------------------------------------------------------
@auth.route('/forgot-password', methods=['GET', 'POST'])
def forgot_password():
    if request.method == 'POST':
        email = request.form.get('email', '').strip()

        conn   = get_db_connection()
        cursor = get_cursor(conn)

        lockout_until = _get_otp_lockout(cursor, email)
        if lockout_until:
            conn.commit(); cursor.close(); conn.close()
            remaining = lockout_until - datetime.now()
            h, rem = divmod(int(remaining.total_seconds()), 3600)
            m = rem // 60
            flash(f'This account is temporarily locked. Please try again in {h}h {m}m.', 'error')
            return render_template('forgot_password.html')

        user      = None
        user_type = None
        unique_id = None

        # Check Students first
        cursor.execute("SELECT user_id, email FROM Students WHERE email = %s", (email,))
        user = cursor.fetchone()
        if user:
            user_type = 'student'
            unique_id = user['user_id']

        # Then Teachers
        if not user:
            cursor.execute("SELECT user_id, email FROM Teachers WHERE email = %s", (email,))
            user = cursor.fetchone()
            if user:
                user_type = 'teacher'
                unique_id = user['user_id']

        # Then Admins
        if not user:
            cursor.execute("SELECT username, email FROM Admins WHERE email = %s", (email,))
            user = cursor.fetchone()
            if user:
                user_type = 'admin'
                unique_id = user['username']

        if user:
            otp = generate_otp()
            session['reset_otp']       = otp
            session['reset_email']     = email
            session['reset_unique_id'] = unique_id
            session['reset_type']      = user_type
            session['otp_expiry']      = (datetime.now() + timedelta(minutes=10)).timestamp()
            session['otp_send_count']  = 1
            session['otp_last_sent']   = datetime.now().timestamp()
            session['otp_wrong_count'] = 0

            if send_otp_email(email, otp, unique_id):
                flash('OTP sent to your email. Check your inbox for your code and Unique ID.', 'success')
            else:
                flash('Failed to send email. Please contact support.', 'error')

            cursor.close(); conn.close()
            return redirect(url_for('auth.verify_otp'))
        else:
            flash('Email not found in our records.', 'error')

        cursor.close(); conn.close()

    return render_template('forgot_password.html')


@auth.route('/resend-otp')
def resend_otp():
    email = session.get('reset_email')
    if not email:
        flash('Session expired. Please try again.', 'error')
        return redirect(url_for('auth.forgot_password'))

    conn   = get_db_connection()
    cursor = get_cursor(conn)

    lockout_until = _get_otp_lockout(cursor, email)
    if lockout_until:
        conn.commit(); cursor.close(); conn.close()
        remaining = lockout_until - datetime.now()
        h, rem = divmod(int(remaining.total_seconds()), 3600)
        m = rem // 60
        _clear_otp_session()
        flash(f'Your account is locked for {h}h {m}m. Please try again later.', 'error')
        return redirect(url_for('auth.forgot_password'))

    send_count = session.get('otp_send_count', 0)
    if send_count >= OTP_MAX_SENDS:
        _set_otp_lockout(conn, cursor, email)
        cursor.close(); conn.close()
        flash(f'Maximum OTP requests reached ({OTP_MAX_SENDS}). Account locked for {OTP_LOCKOUT_HOURS} hours.', 'error')
        return redirect(url_for('auth.forgot_password'))

    last_sent = session.get('otp_last_sent', 0)
    elapsed   = datetime.now().timestamp() - last_sent
    if elapsed < OTP_COOLDOWN_SECS:
        wait = int(OTP_COOLDOWN_SECS - elapsed)
        cursor.close(); conn.close()
        flash(f'Please wait {wait} second(s) before requesting another OTP.', 'error')
        return redirect(url_for('auth.verify_otp'))

    cursor.close(); conn.close()

    unique_id = session.get('reset_unique_id', '')
    otp = generate_otp()
    session['reset_otp']      = otp
    session['otp_expiry']     = (datetime.now() + timedelta(minutes=10)).timestamp()
    session['otp_send_count'] = send_count + 1
    session['otp_last_sent']  = datetime.now().timestamp()

    if send_otp_email(email, otp, unique_id):
        remaining_sends = OTP_MAX_SENDS - (send_count + 1)
        flash(f'A new OTP has been sent. You have {remaining_sends} resend(s) remaining.', 'success')
    else:
        flash('Failed to send email. Please try again.', 'error')

    return redirect(url_for('auth.verify_otp'))


@auth.route('/verify-otp', methods=['GET', 'POST'])
def verify_otp():
    if 'reset_otp' not in session:
        return redirect(url_for('auth.forgot_password'))

    email         = session.get('reset_email', '')
    send_count    = session.get('otp_send_count', 1)
    wrong_count   = session.get('otp_wrong_count', 0)
    last_sent     = session.get('otp_last_sent', 0)
    resends_left  = max(0, OTP_MAX_SENDS - send_count)
    cooldown_ends = int(last_sent + OTP_COOLDOWN_SECS)

    if request.method == 'POST':
        entered_otp = request.form.get('otp')

        if email:
            conn   = get_db_connection()
            cursor = get_cursor(conn)
            lockout_until = _get_otp_lockout(cursor, email)
            conn.commit(); cursor.close(); conn.close()
            if lockout_until:
                remaining = lockout_until - datetime.now()
                h, rem = divmod(int(remaining.total_seconds()), 3600)
                m = rem // 60
                _clear_otp_session()
                flash(f'Your account is locked for {h}h {m}m. Try again later.', 'error')
                return redirect(url_for('auth.forgot_password'))

        if datetime.now().timestamp() > session.get('otp_expiry', 0):
            flash('OTP has expired. Please request a new one.', 'error')
            return redirect(url_for('auth.forgot_password'))

        if entered_otp == session.get('reset_otp'):
            session['otp_verified']    = True
            session['otp_wrong_count'] = 0
            return redirect(url_for('auth.reset_password'))
        else:
            wrong_count += 1
            session['otp_wrong_count'] = wrong_count
            attempts_left = OTP_MAX_WRONG - wrong_count
            if wrong_count >= OTP_MAX_WRONG:
                if email:
                    conn   = get_db_connection()
                    cursor = get_cursor(conn)
                    _set_otp_lockout(conn, cursor, email)
                    cursor.close(); conn.close()
                flash(f'Too many incorrect attempts. Account locked for {OTP_LOCKOUT_HOURS} hours.', 'error')
                return redirect(url_for('auth.forgot_password'))
            else:
                flash(f'Invalid OTP. You have {attempts_left} attempt(s) remaining.', 'error')

    return render_template(
        'verify_otp.html',
        resends_left=resends_left,
        cooldown_ends=cooldown_ends,
        wrong_count=session.get('otp_wrong_count', 0),
        max_wrong=OTP_MAX_WRONG
    )


@auth.route('/reset-password', methods=['GET', 'POST'])
def reset_password():
    if not session.get('otp_verified'):
        return redirect(url_for('auth.forgot_password'))

    if request.method == 'POST':
        new_password     = request.form.get('password')
        confirm_password = request.form.get('confirm_password')

        if new_password != confirm_password:
            flash('Passwords do not match.', 'error')
            return render_template('reset_password.html')

        email     = session.get('reset_email')
        user_type = session.get('reset_type')

        conn      = get_db_connection()
        cursor    = get_cursor(conn)
        hashed_pw = generate_password_hash(new_password)

        if user_type == 'student':
            cursor.execute(
                "UPDATE Students SET password_hash = %s, failed_attempts = 0, lockout_time = NULL WHERE email = %s",
                (hashed_pw, email)
            )
        elif user_type == 'teacher':
            cursor.execute(
                "UPDATE Teachers SET password_hash = %s, failed_attempts = 0, lockout_time = NULL WHERE email = %s",
                (hashed_pw, email)
            )
        elif user_type == 'admin':
            cursor.execute(
                "UPDATE Admins SET password_hash = %s, failed_attempts = 0, lockout_time = NULL WHERE email = %s",
                (hashed_pw, email)
            )

        conn.commit()
        cursor.close()
        conn.close()

        _clear_otp_session()
        session.pop('reset_unique_id', None)

        flash('Password reset successful! You can now login.', 'success')
        if user_type == 'admin':
            return redirect(url_for('auth.admin_login'))
        else:
            return redirect(url_for('auth.student_login'))  # unified login covers both

    return render_template('reset_password.html')


@auth.route('/logout')
def logout():
    role   = session.get('role')
    log_id = session.get('login_log_id')

    if log_id:
        try:
            conn = get_db_connection()
            if conn:
                cursor = get_cursor(conn)
                cursor.execute("UPDATE login_logs SET logout_time = NOW() WHERE log_id = %s", (log_id,))
                conn.commit()
                cursor.close()
                conn.close()
        except Exception as e:
            print(f"Error updating logout time: {e}")

    session.clear()
    if role == 'admin':
        return redirect(url_for('auth.admin_login'))
    return redirect(url_for('auth.student_login'))


@auth.route('/change-password', methods=['GET', 'POST'])
def change_password():
    if 'user_id' not in session:
        return redirect(url_for('auth.login_redirect'))

    if request.method == 'POST':
        current_password = request.form.get('current_password')
        new_password     = request.form.get('new_password')
        confirm_password = request.form.get('confirm_password')

        if new_password != confirm_password:
            flash('Passwords do not match.', 'error')
            return render_template('change_password.html')

        role = session.get('role')
        uID  = session.get('user_id')

        conn   = get_db_connection()
        cursor = get_cursor(conn)

        if role == 'student':
            table  = 'Students'
            id_col = 'user_id'
        elif role == 'teacher':
            table  = 'Teachers'
            id_col = 'user_id'
        else:
            table  = 'Admins'
            id_col = 'admin_id'

        cursor.execute(f"SELECT * FROM {table} WHERE {id_col} = %s", (uID,))
        user = cursor.fetchone()

        if user and user['password_hash'] and check_password_hash(user['password_hash'], current_password):
            new_hash = generate_password_hash(new_password)
            cursor.execute(f"UPDATE {table} SET password_hash = %s WHERE {id_col} = %s", (new_hash, uID))
            conn.commit()
            flash('Password updated successfully.', 'success')
            dest = 'user.dashboard' if role == 'student' else 'teacher.dashboard' if role == 'teacher' else 'admin.dashboard'
            cursor.close()
            conn.close()
            return redirect(url_for(dest))
        else:
            flash('Incorrect current password.', 'error')

        cursor.close()
        conn.close()

    return render_template('change_password.html')
