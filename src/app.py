"""
This module contains contains the core logic of the server. It provides the mapping of all
communication between users, friends and the database. We are using the Flask framework to
handle the server logic.

Endpoints will be exposed at http://localhost:3001/<endpoint>

Design Pattern
----------------------
This component of our application follows the Mediator design pattern as it
    1. Promotes loose coupling by keeping users from referring to each other explicitly.
       Any request for data, locations, updating information must go through this module
    2. Promotoes a many-to-many relationship. Each user must communicate with every one of
       its friends, and every user has a different friend list. This complicated communication
       is abstracted away by the mediator (app.py)


Information Hiding Principle
----------------------
All modules that interact with this module must conform to the interface of this class. The only
parts exposed to other classes are fundamental methods that are not likely to change.


A Note on Return Types
----------------------
Each endpoint, denoted by "@app.route", receives an HTTP Request as its argument and returns
a Flask Response object, containing the HTTP status and a data field.
"""

import logging
import json
from flask import Flask, request, Response
from db import Db

app = Flask(__name__)
db = Db()


def create_test_app(uri):
    global db, app
    db = Db(uri)
    return app


@app.route('/addUser', methods=['GET'])
def add_user():
    """
    Endpoint: /addUser
    Adds a new user to the database.

    Arguments
    --------------------
        user_name       -- a string, username of a new user

    Response
    --------------------
        Code: 200       -- Success
        Code: 400       -- User already exists
                        -- No username provided
    """
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
    """
    Endpoint: /addUser
    Adds friend to user's friends list. Enpoint /addFriend.

    Arguments
    --------------------
        user_name       -- a string, user
        friend_name     -- a string, friend to be added

    Response
    --------------------
        Code: 200       -- Success
        Code: 400       -- User does not exist
                        -- No username or friend was provided
    """
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
    """
    Enpoint: /addFriend.
    Adds friend to user's friends list.

    Arguments
    --------------------
        user_name       -- a string, user
        friend_name     -- a string, friend to be added

    Response
    --------------------
        Code: 200       -- Success
        Code: 400       -- Friend does not exist
                        -- No username or friend was provided
    """
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
    """
    Endpoint: /registerLocation
    Register a user's most recent location.

    Arguments
    --------------------
        user_name       -- a string, user
        location        -- JSON object, Location object formatted as JSON. Contains either GPS data
                           for outdoor locations or Indoor Formatted for indoor locations.

    Response
    --------------------
        Code: 200       -- Success
        Code: 400       -- No such user
    """
    user_name = request.args.get('user_name')
    location = request.json
    res = db.set_location(user_name, location)
    if res:
        return Response('Updated!', status=200)
    return Response('No such user', status=400)


@app.route('/lookup', methods=['GET'])
def lookup_loc():
    """
    Endpoint: /lookup
    Looks up location of a friend for a given user.

    Arguments
    --------------------
        user_name       -- a string, user
        friend_name     -- a string, friend who's location is requested

    Response
    --------------------
        Code: 200       --  Returns a JSON Object containing user's location data
        Code: 400       --  No such user
        Code: 401       --  Access Denied
                        --  Requested friend has not enable location sharing
    """
    user_name = request.args.get('user_name')
    friend_name = request.args.get('friend_name')
    if not user_name or not friend_name:
        logging.info('/lookup_loc: no friend name')
        return Response('Must provide a user and a friend name', status=400)

    # Get list of friends
    # TODO: Have friend list contain location information?
    friends_list = db.get_friends_list(user_name)
    if friends_list is None:
        return Response('No such user', status=400)

    # Is requested user in our friend list?
    if friend_name not in friends_list:
        logging.info('/lookup_loc: illegal friend lookup')
        return Response("Friend not found", status=400)

    # Is friend sharing location?
    location = db.get_location(friend_name)
    if location is None:
        return Response('Friend has location toggled off', status=401)
    
    # Get location
    return Response(json.dumps(location), status=200)


@app.route('/toggle', methods=['GET'])
def toggle_loc():
    """
    Toggle user's location sharing on and off. Endpoint /toggle.

    Arguments
    --------------------
        user_name       -- a string, user who is toggling their location

    Response
    --------------------
        Code: 200       -- Success
        Code: 400       -- No user name provided.
    """
    user_name = request.args.get('user_name')
    if not user_name:
        logging.info('/toggle: No user name')
        return Response('Must provide a user name', status=400)
    res = db.toggle(user_name)
    if not res:
        return Response("User doesn't exist", status=400)
    return Response("Toggled!", status=200)

@app.route('/addBuilding', methods=['POST'])
def add_building():
    """
    Endpoint: /addBuilding
    Add buildings to building list.

    Arguments
    --------------------
        building_name       -- a string, building's name
        location            -- JSON object, Location object formatted as JSON. Contains GPS data.
        num_of_floors       -- a string, number of floors in the building

    Response
    --------------------
        Code: 200       -- Success
        Code: 400       -- Missing building name, number of floors, or location, 
                           or building already exists and cannot be added as a new building
    """
    building_name = request.args.get('building_name')
    location = request.json
    num_floors = request.args.get('num_of_floors')
    footprint = []
    if not building_name:
        return Response("Must provide building name", status=400)
    if not num_floors:
        return Response("Must provide number of floors", status=400)
    if not location:
        return Response("Must provide building location", status=400)
        
    num_floors = int(num_floors)
    added = db.add_building(building_name, location, num_floors, footprint)
    if added:
        return Response("Building is added.", status=200)
    return Response("Building already exists.", status=400)

'''
@app.route('/addFloor', methods=['POST'])
def add_floor():
    building = request.args.get('building_name')
    floor_number = request.args.get('floor_number')
    image = building + '_floor_' + floor_numer + '.png'
    floor_plan = request.
'''

if __name__ == '__main__':
    app.run(host='127.0.0.1')
