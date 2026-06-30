from flask import Flask, redirect, url_for, request
from Voxify.__init__ import create_app
from Voxify.Authentication.routes import _get_sso_user

app = create_app()


@app.route('/')
def home():
    """
    Verify the auth_token cookie directly against the Portal (same check
    the SSO decorators use) instead of relying on session['user_id']
    being set by an earlier request — that dependency caused a redirect
    loop, since '/' itself has no decorator to populate the session.
    """
    user = _get_sso_user()

    if user:
        role = user.get('role')
        if role == 'superadmin':
            return redirect(url_for('super_admin.dashboard'))
        elif role == 'admin':
            return redirect(url_for('admin.dashboard'))
        elif role == 'voter':
            return redirect(url_for('voter.dashboard'))
        # Unknown role but valid token — avoid looping back to '/'
        return redirect(url_for('voter.dashboard'))

    # No valid token: go straight to the Portal, not back through
    # auth.voter_login (which would just redirect here again).
    portal_url = "http://127.0.0.1:5000"
    return redirect(f"{portal_url}?next={request.host_url}")


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5001)