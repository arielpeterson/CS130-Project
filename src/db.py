"""
Database module implemented using MongoDB.

Design Pattern
----------------------
This module is implemented using a Singleton design pattern. Instantiation of
the class is restricted to only one class instance. If multiple databases are created,
there is no gaurantee of synchronoization across these instances. The Singleton design
proactively prevents such errors.

Information Hiding Principle
-----------------------------
The interface to the database is accomplished through a "Db" class, rather than exposing
the internals of MongoDB. These methods that are unlikely to change, but the database may.
"""

import os
import logging
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure

# Temporary
os.environ['MONGO_URI'] = 'mongodb://localhost:27017'
os.environ['USER_TABLE'] = 'User'
os.environ['BUILDING_TABLE'] = 'Building'


class Db(object):

    MONGO_URI = os.environ['MONGO_URI']
    USER_TABLE = os.environ['USER_TABLE']
    _db = None

    def __new__(cls, uri=MONGO_URI,db='wya'):
        """
        Overrides __new__ to ensure only a single instance is created
        """
        if cls._db == None:
            cls._db = object.__new__(cls)
        return cls._db

    def __init__(self, uri=MONGO_URI, db='wya'):
        """
        Initializes database using a singleton design pattern
        """
        self._db = MongoClient(uri)[db]

    def add_user(self, user_name):
        """
        Adds a new user to the database

        Arguments
        --------------------
            user_name       -- a string, username of user to be added

        Return
        --------------------
            result          -- a Boolean, indicates success or failure
        """
        if self._db[self.USER_TABLE].find_one({'user': user_name}) is not None:
            return False

        # Add new user. Location Sharing defaults to false
        self._db[self.USER_TABLE].insert_one({'user': user_name, 
                                              'location_sharing': False,
                                              'friends_list': []})
        return True

    def get_friends_list(self, user_name):
        """
        Get list of friends for a given user

        Arguments
        --------------------
            user_name       -- a string, user

        Return
        --------------------
            friends_list     -- a list, all user's current friends
                            or
                            -- None type, if there was no entry in databasse
        """
        user = self._db[self.USER_TABLE].find_one({'user': user_name})
        if user is None:
            return None
        return user.get('friends_list')

    def add_friend(self, user_name, friend_name):
        """
        Add a friend to a user's friends list

        Arguments
        --------------------
            user_name       -- a string, user
            friend_name     -- a string, friend to be deleted

        Return
        --------------------
            result          -- a Boolean, indicates success or failure
        """
        friends_list = self.get_friends_list(user_name)
        if friends_list is None:         # No such user
            return False
        if friend_name in friends_list:  # Don't add duplicates
            return False

        # Make update
        res = self._db[self.USER_TABLE].update_one({'user': user_name}, {'$push': {'friends_list': friend_name}})
        if res.matched_count == 0: # Success or failure?
            return False
        return True


    def delete_friend(self, user_name, friend_name):
        """
        Delete a friend from a user's friends list

        Arguments
        --------------------
            user_name       -- a string, user
            friend_name     -- a string, friend to be deleted

        Return
        --------------------
            result          -- a Boolean, indicates success or failure
        """
        # Unfortunately we need to query the friends_list, search for the user, and remove
        friends_list = self.get_friends_list(user_name)
        # If no friends, we are done
        if not friends_list:
            return False
        try:
            friends_list.remove(friend_name)
        except ValueError:
            logging.info('Could not remove {} because user {} does not have them in friends list'.format(friend_name, user_name))
            return False

        self._db[self.USER_TABLE].update_one({'user': user_name}, {'$set': {'friends_list': friends_list}})
        return True

    def get_location(self, friend_name):
        """
        Query database for location of specified user

        Arguments
        --------------------
            friend_name     -- a string, friendname

        Return
        --------------------
            location        -- JSON String, location of friend_name 
                            or
                            -- None type, if there was no entry or not valid lookup
        """
        user = self._db[self.USER_TABLE].find_one({'user': friend_name})

        # Does the user exist?
        if user is None:
            return None

        # Is locatin_sharing enabled?
        if not user['location_sharing']:
            return None
        
        return user.get('location')

    def set_location(self, user_name, location):
        """
        Update user with new location from device

        Arguments
        --------------------
            user_name       -- a string, user
            location        -- location, most recent location of user

        Return
        --------------------
            result          -- a Boolean, indicates success or failure
        """
        res = self._db[self.USER_TABLE].update_one({'user': user_name}, {'$set': {'location': location}})
        if res.matched_count == 0:
            return False
        return True

    def toggle(self, user_name):
        """
        Toggle user's location sharing

        Arguments
        --------------------
            user_name       -- a string, user

        Return
        --------------------
            result          -- a Boolean, returns False if user doesn't exist
                               and true otherwise.
        """
        user = self._db[self.USER_TABLE].find_one({'user': user_name})

        if user is None:
            return False

        # Toggle location setting
        toggle = user.get('location_sharing')
        self._db[self.USER_TABLE].update_one({'user': user_name}, {'$set': {'location_sharing': not toggle}})
        return True

    def register_indoor(self, user_name, location, room):
        """
        Register a user's indoor location

        Arguments
        --------------------
            user_name       -- a String, the name of the user
            location        -- a dictionary, keys: 'x', 'y', 'building', 'floor'
            room            -- an int, the detected room number of user

        Return
        --------------------
            result          -- a Boolean, return success or failure
        """
        location['room'] = room
        try:
            self._db[self.USER_TABLE].update_one({'user': user_name}, {'$set': {'indoor_location': location}})
            return True
        except Exception:
            return False

    def get_building(self, building_name):
        """
        Get information about a building and each of its floors

        Arguments
        --------------------
            building_name       -- a String, the name of the building

        Return
        --------------------
            building          -- a list of dictionaries, keys: 'floor', 'vertices'
        """
        floors = self._db[self.BUILDING_TABLE].find({'building_name': building_name}, {'building_name': 0})
        return floors

    def add_floor(self, building_name, floor, vertices):
        res = self._db[self.BUILDING_TABLE].insert_one({'building_name': building_name,
                                                        'vertices': vertices,
                                                        'floor': floor})
        if not res.acknowledged:
            return False
        return True

