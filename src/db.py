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

    def __new__(cls):
        if cls._db == None:
            cls._db = object.__new__(cls)
        return cls._db

    def __init__(self):
        self._db = MongoClient(self.MONGO_URI)['wya']

    def add_user(self, user_name):
        """Add a new user"""
        if self._db[self.USER_TABLE].find_one({'user': user_name}) is not None:
            return False

        self._db[self.USER_TABLE].insert_one({'user': user_name})
        return True

    def get_friends_list(self, user_name):
        """Get list of friends for a given user"""
        l = self._db[self.USER_TABLE].find_one({'user': user_name})
        if l is not None:
            return l.get('friendsList')
        return None

    def add_friend(self, user_name, friend_name):
        """Add friend to user's friends list"""
        res = self._db[self.USER_TABLE].update_one({'user': user_name}, {'$push': {'friendsList': friend_name}})
        # Check if user exists
        if res.matched_count == 0:
            return False
        return True

    def delete_friend(self, user_name, friend_name):
        """Delete a friend from a user's friends list"""
        # Unfortunately we need to query the friends_list, search for the user, and remove
        friends_list = self.get_friends_list(user_name)
        print(friends_list)
        # If no friends, we are done
        if not friends_list:
            return False
        try:
            friends_list.remove(friend_name)
        except ValueError:
            logging.info('Could not remove {} because user {} does not have them in friends list'.format(friend_name, user_name))
            print('here')
            return False
        
        self._db[self.USER_TABLE].update_one({'user': user_name}, {'$set': {'friendsList': friends_list}})
        return True
    
    def get_location(self, friend_name):
        """Query database for location of specified user"""
        l = self._db[self.USER_TABLE].find_one({'user': friend_name})
        if l is not None:
            return l.get('location')
        return None

    def set_location(self, user_name, location):
        """Update user with new location from device"""
        res = self._db[self.USER_TABLE].update_one({'user': user_name}, {'$set': {'location': location}})
        if res.matched_count == 0:
            return False
        return True

    def toggle(self, user_name):
        """Toggle user's location sharing"""
        l = self._db[self.USER_TABLE].find_one({'user': user_name})
        if l is None:
            return None
        toggle = l.get('location_sharing')
        if toggle is not None:
            self._db[self.USER_TABLE].update_one({'user': user_name}, {'$set': {'location_sharing': not toggle}})
        else:
            self._db[self.USER_TABLE].update_one({'user': user_name}, {'$set': {'location_sharing': False}})

    def location_available(self, user_name):
        """Check if user's location is toggled off"""
        l = self._db[self.USER_TABLE].find_one({'user': user_name})
        if l is not None:
            return l.get('location_sharing')
        return None