import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

from Main.__init__ import reg_app

app = reg_app()

if __name__ == '__main__':
    debug_mode = os.getenv('FLASK_DEBUG', 'True').lower() == 'true'
    # host='0.0.0.0' binds to all network interfaces so the app is reachable
    # from any device on the same Wi-Fi/hotspot using http://<laptop-ip>:5000
    # SSL disabled temporarily for testing - will use adhoc SSL instead
    app.run(
        debug=debug_mode, 
        host='0.0.0.0', 
        port=5000,
        ssl_context='adhoc'
    )