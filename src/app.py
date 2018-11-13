import logging

import flask import Flask, request

app = Flask(__name__)
db = Db()

@app.route('/addFriend')
def add_friend():
    """Add user to friends list"""
    user_name = request.args.get('user_name')
    friend_name = request.args.get('friend_name')
    if not user_name or not friend_name:
        logging.info('/add_friend: no user name or friend name')
        return 'Must provide user name and friend name'
    db.add_friend(user_name, friend_name)
    return 'Added!'


@app.route('/deleteFriend')
def delete_friend():
    """Remove user from friends list"""
    user_name = request.args.get('user_name')
    friend_name = request.args.get('friend_name')
    if not user_name or not friend_name:
        logging.info('/delete_friend: no user name or friend name')
        return 'Must provide user name and friend name'
    db.delete_friend(user_name, friend_name)
    return 'Removed!'


@app.route('/lookup')
def lookup_loc():
    """Look up a user's current location"""
    friend_name = request.args.get('friend_name')
    if not friend_name:
        logging.info('/lookup_loc: no friend name')
        return 'Must provide a friend name'
    location = db.get_location(friend_name)
    return str(location)


@app.route('/toggle')
def toggle_loc():
    """Toggle user location on and off"""
    user_name = request.args.get('user_name')
    if not user_name:
        logging.info('/toggle: No user name')
        return 'Must provide a user name'
    db.toggle_loc(user_name)
    return "Toggled!"
