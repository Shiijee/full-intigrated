import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

from Main.__init__ import reg_app

app = reg_app()

if __name__ == '__main__':
    debug_mode = os.getenv('FLASK_DEBUG', 'True').lower() == 'true'
    cert_path = os.path.join(os.path.dirname(__file__), 'cert.pem')
    key_path = os.path.join(os.path.dirname(__file__), 'key.pem')
    if os.path.exists(cert_path) and os.path.exists(key_path):
        app.run(debug=debug_mode, host='0.0.0.0', port=5002, ssl_context=(cert_path, key_path))
    else:
        app.run(debug=debug_mode, host='0.0.0.0', port=5002)
