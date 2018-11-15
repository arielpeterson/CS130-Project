import logging
import json

from flask import Flask, request, Response, jsonify

from db import Db
from location import IndoorLocation, OutdoorLocation

app = Flask(__name__)
db = Db()


@app.route('/addUser', methods=['GET'])
def add_user():
    """Add a new user to db"""
    user_name = request.args.get('user_name')
    if not user_name:
        logging.info('/addUser: no user name')
        return Response('Must provide user name', status=400)
    added = db.add_user(user_name)
    if added:
        return Response("Signed up!", status=200)
    return Response('User already exists', status=400)


@app.route('/addFriend', methods=['GET'])
def add_friend():
    """Add user to friends list"""
    user_name = request.args.get('user_name')
    friend_name = request.args.get('friend_name')
    if not user_name or not friend_name:
        logging.info('/add_friend: no user name or friend name')
        return Response('Must provide user name and friend name', status=400)
    res = db.add_friend(user_name, friend_name)
    if res:
        return Response('Added!', status=200)
    return Response("Cannot add friend to user's friends list, user does not exist", status=400)


@app.route('/deleteFriend', methods=['GET'])
def delete_friend():
    """Remove user from friends list"""
    user_name = request.args.get('user_name')
    friend_name = request.args.get('friend_name')
    if not user_name or not friend_name:
        logging.info('/delete_friend: no user name or friend name')
        return Response('Must provide user name and friend name', status=400)
    res = db.delete_friend(user_name, friend_name)
    if res:
        return Response('Removed!', status=200)
    return Response('Friend does not exist', status=400)


@app.route('/registerLocation', methods=['POST'])
def register():
    """Register a user's most recent location"""
    user_name = request.args.get('user_name')
    location = request.json
    res = db.set_location(user_name, location)
    if res:
        return Response('Updated!', status=200)
    return Response('No such user', status=400)


@app.route('/lookup', methods=['GET'])
def lookup_loc():
    """Look up a user's current location"""
    user_name = request.args.get('user_name')
    friend_name = request.args.get('friend_name')
    if not friend_name:
        print('no friend_name')
        logging.info('/lookup_loc: no friend name')
        return Response('Must provide a friend name', status=400)

    # Ensure user exists is allowed to view location still
    friends_list = db.get_friends_list(user_name)
    if friends_list is None:
        return Response('No such user', status=400)

    if not db.location_available(user_name):
        return Response('Friend has location toggled off', status=401)

    if friend_name not in friends_list:
        print('access denied')
        logging.info('/lookup_loc: illegal friend lookup')
        return Response("Not authroized to view this user's location", status=401)

    location = db.get_location(friend_name)
    if location is None:
        return Response('No such user', status=400)
    return Response(json.dumps(location), status=200)


@app.route('/toggle', methods=['GET'])
def toggle_loc():
    """Toggle user location on and off"""
    user_name = request.args.get('user_name')
    if not user_name:
        logging.info('/toggle: No user name')
        return Response('Must provide a user name', status=400)
    db.toggle(user_name)
    return Response("Toggled!", status=200)


if __name__ == '__main__':
    app.run(host='0.0.0.0')
