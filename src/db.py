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
import numpy as np
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure

# Temporary
os.environ['MONGO_URI'] = 'mongodb://localhost:27017'
os.environ['USER_TABLE'] = 'User'
os.environ['BUILDING_TABLE'] = 'Building'


class Db(object):

    MONGO_URI = os.environ['MONGO_URI']
    USER_TABLE = os.environ['USER_TABLE']
    BUILDING_TABLE = os.environ['BUILDING_TABLE']
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

    def add_user(self, user_name, email):
        """
        Adds a new user to the database

        Arguments
        --------------------
            user_name       -- a string, username of user to be added

        Return
        --------------------
            result          -- a Boolean, indicates success or failure
        """
        # User already exists
        if self._db[self.USER_TABLE].find_one({'email': email}) is not None:
            return False

        # Add new user. Location Sharing defaults to false
        self._db[self.USER_TABLE].insert_one({'user': user_name,
                                              'email': email,
                                              'location_sharing': True,
                                              'friends_list': []})
        return True

    def get_friends_list(self, user_email):
        """
        Get list of friends for a given user

        Arguments
        --------------------
            user_email       -- a string, user

        Return
        --------------------
            friends_list     -- a list, all user's current friends
                            or
                            -- None type, if there was no entry in databasse
        """
        user = self._db[self.USER_TABLE].find_one({'email': user_email})
        if user is None:
            return None
        return user.get('friends_list')

    def get_name(self, email):
        """
        Get user for a given email

        Arguments
        --------------------
            email           -- a string, email

        Return
        --------------------
            name            -- a string, user
                            or
                            -- None type, if there was no entry in databasse
        """
        user = self._db[self.USER_TABLE].find_one({'email': email})
        if user is None:
            return None
        return user.get('user')

    def add_friend(self, user_email, friend_email):
        """
        Add a friend to a user's friends list

        Arguments
        --------------------
            user_email       -- a string, user
            friend_email     -- a string, friend to be added

        Return
        --------------------
            result          -- a Boolean, indicates success or failure
        """
        friends_list = self.get_friends_list(user_email)
        if friends_list is None:         # No such user
            return False
        if friend_email in friends_list:  # Don't add duplicates
            return False
            
        friend = self._db[self.USER_TABLE].find_one({'email': friend_email})
        if not friend:                  # Don't add someone who isn't a user
            return False

        # Make update
        res = self._db[self.USER_TABLE].update_one({'email': user_email}, {'$push': {'friends_list': friend_email}})
        if res.matched_count == 0: # Success or failure?
            return False
        return True


    def delete_friend(self, user_email, friend_email):
        """
        Delete a friend from a user's friends list

        Arguments
        --------------------
            user_email      -- a string, user
            friend_email    -- a string, friend to be deleted

        Return
        --------------------
            result          -- a Boolean, indicates success or failure
        """
        # Unfortunately we need to query the friends_list, search for the user, and remove
        friends_list = self.get_friends_list(user_email)
        # If no friends, we are done
        if not friends_list:
            return False
        try:
            friends_list.remove(friend_email)
        except ValueError:
            logging.info('Could not remove {} because user {} does not have them in friends list'.format(friend_email, user_email))
            return False

        self._db[self.USER_TABLE].update_one({'email': user_email}, {'$set': {'friends_list': friends_list}})
        return True

    def get_location(self, friend_email):
        """
        Query database for location of specified user

        Arguments
        --------------------
            friend_email    -- a string, friend's email

        Return
        --------------------
            location        -- JSON String, location of friend_name 
                            or
                            -- None type, if there was no entry or not valid lookup
        """
        user = self._db[self.USER_TABLE].find_one({'email': friend_email})

        # Does the user exist?
        if user is None:
            return None, None

        # Is locatin_sharing enabled?
        if not user['location_sharing']:
            return None, None
        
        return {'outdoor_location': user.get('location'), 'indoor_location': user.get('indoor_location')}, user.get('last_seen_indoor')

    def set_location(self, user_email, location):
        """
        Update user with new location from device

        Arguments
        --------------------
            user_email       -- a string, user
            location        -- location, most recent location of user

        Return
        --------------------
            result          -- a Boolean, indicates success or failure
        """
        res = self._db[self.USER_TABLE].update_one({'email': user_email}, {'$set': {'location': location}})
        if res.matched_count == 0:
            return False
        return True

    def toggle(self, user_email):
        """
        Toggle user's location sharing

        Arguments
        --------------------
            user_email       -- a string, user

        Return
        --------------------
            result          -- a Boolean, returns False if user doesn't exist
                               and true otherwise.
        """
        user = self._db[self.USER_TABLE].find_one({'email': user_email})

        if user is None:
            return False

        # Toggle location setting
        toggle = user.get('location_sharing')
        self._db[self.USER_TABLE].update_one({'email': user_email}, {'$set': {'location_sharing': not toggle}})
        return True

    def register_indoor(self, user_email, location, room, last_seen):
        """
        Register a user's indoor location

        Arguments
        --------------------
            user_email      -- a String, the name of the user
            location        -- a dictionary, keys: 'x', 'y', 'z', 'building', 'floor'
            room            -- an int, the detected room number of user
            last_seen       -- a float, the timestamp of when indoor location is registered

        Return
        --------------------
            result          -- a Boolean, return success or failure
        """
        location['room'] = room
        try:
            print("Success if this is not 0 -----> {}".format(res.matched_count))
            res = self._db[self.USER_TABLE].update_one({'email': user_email}, {'$set': {'indoor_location': location}})
            res = self._db[self.USER_TABLE].update_one({'email': user_email}, {'$set': {'last_seen_indoor': last_seen}})

            if res.matched_count == 0:
                return False
            return True
        except Exception:
            return False

    def get_building(self, building_name):
        """
        Get information about a building and each of its floors

        Arguments
        --------------------
            building_name   -- a String, the name of the building

        Return
        --------------------
            floors          -- a list of dictionaries, keys: 'floor', 'vertices'
        """
        floors = list(self._db[self.BUILDING_TABLE].find({'building_name': building_name}, {'building_name': 0, 'location': 0}))
        
        for floor in floors:
            if 'floor' in floor:
                continue
            else:
                floors.remove(floor)
                break
        return floors

    def add_floor(self, building_name, floor, vertices):
        """
        Add a floor to an existing building

        Arguments
        --------------------
            building_name   -- a String, building name
            floor           -- an int, floor
            vertices        -- a list of floor vertices

        Return
        --------------------
            result          -- a Boolean, return success or failure
        """
        building = self._db[self.BUILDING_TABLE].find_one({'building_name': building_name})
        if not building:
            return False
        location = building['location']
        res = self._db[self.BUILDING_TABLE].insert_one({'building_name': building_name,
                                                        'location': location,
                                                        'vertices': vertices,
                                                        'floor': floor})
        if not res.acknowledged:
            return False
        return True

    def add_building(self, building_name, location):
        """
        add a new building

        Arguments
        --------------------
            building_name   -- a string, building_name

        Return
        --------------------
            result          -- a Boolean, returns true if successfully added
                               and false otherwise.
        """
        
        building = self._db[self.BUILDING_TABLE].find_one({'building_name': building_name})
        if not building:        
            res = self._db[self.BUILDING_TABLE].insert_one({'building_name': building_name, 'location': location})
            if not res.acknowledged:
                return False
            return True
        return False
        
    def get_building_location(self, building_name):
        """
        get building location


        Arguments
        --------------------
            building_name   -- a string, building_name

        Return
        --------------------
            result          -- building location, None if building does not exist in database
        """
        
        building = self._db[self.BUILDING_TABLE].find_one({'building_name': building_name})
        if not building:
            return None
        return building.get('location')

