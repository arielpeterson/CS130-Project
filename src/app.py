import logging

from flask import Flask, request

from db import Db

app = Flask(__name__)
db = Db()

@app.route('/addUser', methods=['POST'])
def add_user():
    """Add a new user to db"""
    user_name = request.args.get('user_name')
    if not user_name:
        logging.info('/addUser: no user name')
        return 'Must provide user name'
    db.add_user(user_name)
    return "Signed up!"

@app.route('/addFriend', methods=['POST'])
def add_friend():
    """Add user to friends list"""
    user_name = request.args.get('user_name')
    friend_name = request.args.get('friend_name')
    if not user_name or not friend_name:
        logging.info('/add_friend: no user name or friend name')
        return 'Must provide user name and friend name'
    db.add_friend(user_name, friend_name)
    return 'Added!'


@app.route('/deleteFriend', methods=['POST'])
def delete_friend():
    """Remove user from friends list"""
    user_name = request.args.get('user_name')
    friend_name = request.args.get('friend_name')
    if not user_name or not friend_name:
        logging.info('/delete_friend: no user name or friend name')
        return 'Must provide user name and friend name'
    db.delete_friend(user_name, friend_name)
    return 'Removed!'


@app.route('/registerLocation', methods=['POST'])
def register():
    """Register a user's most recent location"""
    user_name = request.args.get('user_name')
    location = request.args.get('location')
    db.set_location(user_name, location)
    return "Updated!"

@app.route('/lookup')
def lookup_loc():
    """Look up a user's current location"""
    user_name = request.args.get('user_name')
    friend_name = request.args.get('friend_name')
    if not friend_name:
        logging.info('/lookup_loc: no friend name')
        return 'Must provide a friend name'

    # Ensure user is allowed to view location still
    friends_list = db.get_friends_list(user_name)
    if friend_name not in friends_list:
        logging.info('/lookup_loc: illegal friend lookup')
        return "Not authroized to view this user's location"

    location = db.get_location(friend_name)
    return str(location)


@app.route('/toggle', methods=['POST'])
def toggle_loc():
    """Toggle user location on and off"""
    user_name = request.args.get('user_name')
    if not user_name:
        logging.info('/toggle: No user name')
        return 'Must provide a user name'
    db.toggle(user_name)
    return "Toggled!"


if __name__ == '__main__':
    app.run(host='0.0.0.0')
