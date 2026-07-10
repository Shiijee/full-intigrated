import smtplib
import random
import string
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os

def generate_otp(length=6):
    """Generate a random numeric OTP."""
    return ''.join(random.choices(string.digits, k=length))

def send_otp_email(recipient_email, otp, username="User"):
    """
    Sends an OTP to the specified email address.
    Returns True if successful, False otherwise.
    """
    sender_email = os.environ.get('MAIL_USERNAME', 'adminattendeez0218@gmail.com')
    sender_password = os.environ.get('MAIL_PASSWORD', '')
    
    if not sender_password:
        print(f"[DEV] OTP for {recipient_email}: {otp}")
        # If no password is provided, we return False so the fallback logic runs 
        # (e.g. showing it on the UI for development purposes).
        return False
        
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = recipient_email
    msg['Subject'] = "Your Verification Code - Attendeez"
    
    body = f"Hello {username},\n\nYour verification code is: {otp}\n\nThis code will expire in 10 minutes."
    msg.attach(MIMEText(body, 'plain'))
    
    try:
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(sender_email, sender_password)
        server.send_message(msg)
        server.quit()
        return True
    except Exception as e:
        print(f"Failed to send email: {e}")
        return False
