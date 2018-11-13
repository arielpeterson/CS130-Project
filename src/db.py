import os
import logging

from pymongo import MongoClient


class Db:
    MONGO_URI = os.environ['MONGO_URI']
    USER_TABLE = os.environ['USER_TABLE']
    def __init__(self):
        self._db = MongoClient(self.MONGO_URI)

    def add_friend(self, user_name, friend_name):
        """Add friend to user's friends list"""
        self._db[self.USER_TABLE].update_one({'user': user_name}, {'$push': {'friendsList': friend_name}})

    def delete_friend(self, user_name, friend_name):
        """Delete a friend from a user's friends list"""
        # Unfortunately we need to query the friends_list, search for the user, and remove
        friends_list = self._db[self.USER_TABLE].find({'user': user_name}).get('friendsList')
        # If no friends, we are done
        if not friends_list:
            return
        try:
            friends_list.remove('friend_name')
        except ValueError:
            logging.info('Could not remove {} because user {} does not have them in friends list'.format(friend_name, user_name))
            return
        
        self._db[self.USER_TABLE].update_one({'user': user_name}, {'$set': {'friendsList': friends_list}})
    
    def get_location(self, friend_name):
        """Query database for location of specified user"""
        return self._db[self.USER_TABLE].find({'user': friend_name}).get('location')

    def toggle(self, user_name):
        """Toggle user's location sharing"""
        self._db[self.USER_TABLE].update_one({'user': user_name}, {'$set': {'location_sharing': False}})