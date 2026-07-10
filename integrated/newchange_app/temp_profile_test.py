from Main import reg_app
app = reg_app()
app.testing = True
with app.test_client() as client:
    with client.session_transaction() as sess:
        sess['user_id'] = 'S26-0002'
        sess['role'] = 'student'
        sess['name'] = 'Test Student'
    resp = client.get('/user/profile', follow_redirects=False)
    print('status', resp.status_code)
    print('location', resp.headers.get('Location'))
    print(resp.get_data(as_text=True)[:500])
