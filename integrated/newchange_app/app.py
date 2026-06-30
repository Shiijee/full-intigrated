import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

from Main.__init__ import reg_app

app = reg_app()

if __name__ == '__main__':
    debug_mode = os.getenv('FLASK_DEBUG', 'True').lower() == 'true'
    app.run(debug=debug_mode, host='0.0.0.0', port=5002)