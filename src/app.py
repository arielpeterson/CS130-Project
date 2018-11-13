import flask import Flask

app = Flask(__name__)
db = Db()

@app.route('/addFriend')
def add_friend():
    """Add user to friends list"""
    pass


@app.route('/deleteFriend')
def delete_friend():
    """Remove user from friends list"""
    pass


@app.route('/lookup')
def lookup_loc():
    """Look up a user's current location"""
    pass


@app.route('/toggle')
def toggle_loc():
    """Toggle user location on and off"""
    pass
