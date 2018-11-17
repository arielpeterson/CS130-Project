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

# Temporary
os.environ['MONGO_URI'] = 'mongodb://localhost:27017'
os.environ['USER_TABLE'] = 'User'


class Db(object):

    MONGO_URI = os.environ['MONGO_URI']
    USER_TABLE = os.environ['USER_TABLE']
    _db = None

    def __new__(cls, uri=MONGO_URI):
        """
        Overrides __new__ to ensure only a single instance is created
        """
        if cls._db == None:
            cls._db = object.__new__(cls)
        return cls._db

    def __init__(self, uri=MONGO_URI):
        """
        Initializes database using a singleton design pattern
        """
        self._db = MongoClient(uri)['wya']

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

        self._db[self.USER_TABLE].insert_one({'user': user_name})
        return True

    def get_friends_list(self, user_name):
        """
        Get list of friends for a given user

        Arguments
        --------------------
            user_name       -- a string, user

        Return
        --------------------
            friendslist     -- a list, all user's current friends
                            or
                            -- None type, if there was no entry in databasse
        """
        l = self._db[self.USER_TABLE].find_one({'user': user_name})
        if l is not None:
            return l.get('friendsList')
        return None

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
        res = self._db[self.USER_TABLE].update_one({'user': user_name}, {'$push': {'friendsList': friend_name}})
        # Check if user exists
        if res.matched_count == 0:
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

        self._db[self.USER_TABLE].update_one({'user': user_name}, {'$set': {'friendsList': friends_list}})
        return True

    def get_location(self, friend_name):
        """
        Query database for location of specified user

        Arguments
        --------------------
            friend_name     -- a string, friendname

        Return
        --------------------
            location        -- a list, all user's current friends
                            or
                            -- None type, if there was no entry in databasse
        """
        l = self._db[self.USER_TABLE].find_one({'user': friend_name})
        if l is not None:
            return l.get('location')
        return None

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
        l = self._db[self.USER_TABLE].find_one({'user': user_name})
        if l is None:
            return False
        toggle = l.get('location_sharing')
        if toggle is not None:
            self._db[self.USER_TABLE].update_one({'user': user_name}, {'$set': {'location_sharing': not toggle}})
        else:
            self._db[self.USER_TABLE].update_one({'user': user_name}, {'$set': {'location_sharing': False}})
        return True

    def location_available(self, user_name):
        """
        Check if user's location is toggled off

        Arguments
        --------------------
            user_name       -- a string, user

        Return
        --------------------
            is_sharing      -- a Boolean, returns True if user is sharing location and
                               false otherwise
                            or
                            -- None type, if User does not exist
        """
        l = self._db[self.USER_TABLE].find_one({'user': user_name})
        if l is not None:
            return l.get('location_sharing')
        return False
