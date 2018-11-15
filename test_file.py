from mockupdb import *
import unittest

# Our own database class using PyMongo
from db import Db

USER_DOC = {'user_name': 'zachrash'}

class ModifyUserTest(unittest.TestCase):
    def setUp(self):
        self.server = MockupDB(auto_ismaster={"maxWireVersion": 6})
        self.server.run()

        # Replace pymongo connection url to use MockupDB
        self.database = Db(self.server.uri)

    def tearDown(self):
        self.server.stop()

    def test_add_valid_friend_valid_user(self):
        user = USER_DOC
        user['friendsList'] = ['bradsquicciarini']

        # Pass a method and its arguments to the go function
        add_user_query = go(self.database.add_friend, 'zachrash', 'bradsquicciarini')

        request = self.server.receives()

        # Return one USER_DOC
        request.reply([USER_DOC])


        self.assertIsInstance(add_user_query()[0]['friendsList'], list)
        self.assertEqual(user['friendsList'], add_user_query()[0]['friendsList'])

    def test_add_invalid_friend_valid_user(self):
        pass

    def test_add_valid_friend_invalid_user(self):
        pass

    def test_add_invalid_friend_invalid_user(self):
        pass

    def test_delete_friend(self):
        pass
