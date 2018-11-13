import os

from pymongo import MongoClient


class Db:
    MONGO_URI = os.environ['MONGO_URI']
    USER_TABLE = os.environ['USER_TABLE']
    def __init__(self):
        self._db = MongoClient(self.MONGO_URI)
    
    def get_location(self, user_name):
        """Query database for location of specified user"""
        return self._db[self.USER_TABLE].find({'user': user_name}).get('location')
