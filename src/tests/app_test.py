import json
import unittest
from mockupdb import MockupDB, go
from context import app

class AppTest(unittest.TestCase):
    '''
        Unit test for app.py. 
        Uses mockupdb to act as the database.
        Each endpoint is tested in a seperate method.
    '''

    def setUp(self):
        ''' Set up test fixtures '''
        self.user = 'i_am_a_user'
        self.server = MockupDB(auto_ismaster={"maxWireVersion": 6})
        self.server.run()
        self.app = app.create_test_app(self.server.uri).test_client()

    def tearDown(self):
        ''' Take down test fixtures '''
        self.server.stop()

    def test_addUser(self):
        '''Test 1: /addUser endpoint'''

        # No username provided
        res = go(self.app.get, '/addUser', query_string={'user_name': ''})
        self.assertEqual(res().status_code, 400)

        # User doesn't exist
        res = go(self.app.get, '/addUser', query_string={'user_name': self.user})
        self.server.reply(cursor={'id': 0, 'firstBatch': [None]})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': self.user}]})
        self.assertEqual(res().status_code, 200)

        # User was added twice
        res = go(self.app.get, '/addUser', query_string={'user_name': self.user})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': self.user}]})
        self.assertEqual(res().status_code, 400)

    def test_addFriend(self):
        ''' Test 2: /addFriend endpoint'''

        # No username/friend provided
        res = go(self.app.get, '/addFriend', query_string={'user_name': '', 'friend_name': ''})
        self.assertEqual(res().status_code, 400)

        # Frined was added successfully
        res = go(self.app.get, '/addFriend', query_string={'user_name': self.user, 'friend_name': 'friend_test'})
        self.server.reply({'n': 1, 'nModified': 1, 'ok': 1.0, 'updatedExisting': True})
        self.assertEqual(res().status_code, 200)

        # Add friend to non-existent user
        res = go(self.app.get, '/addFriend', query_string={'user_name': 'not_a_user', 'friend_name': 'friend_test'})
        self.server.reply({'n': 0, 'nModified': 0, 'ok': 1.0, 'updatedExisting': False})
        self.assertEqual(res().status_code, 400)

    def test_deleteFriend(self):
        ''' Test 3: /deleteFriend endpoint'''

        # Bad arguments
        res = go(self.app.get, '/deleteFriend', query_string={'user_name': '', 'friend_name': ''})
        self.assertEqual(res().status_code, 400)

        # Frined was deleted successfully
        res = go(self.app.get, '/deleteFriend', query_string={'user_name': self.user, 'friend_name': 'delete_me'})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': self.user, 'friendsList': ['delete_me']}]})
        self.server.reply({'n': 1, 'ok': 1.0})
        self.assertEqual(res().status_code, 200)

        # Friend does not exist
        res = go(self.app.get, '/deleteFriend', query_string={'user_name': self.user, 'friend_name': 'i_dont_exist'})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': self.user, 'friendsList': ['i_do_exist']}]})
        self.assertEqual(res().status_code, 400)

    def test_registerLocation(self):
        ''' Test 3: /registerLocation endpoint'''

        # Location update successful
        res = go(self.app.post, '/registerLocation', query_string={'user_name': self.user, 'location': {'latitude': '0.000','longitude': '0.000'}})
        self.server.reply({'n': 1, 'ok': 1.0})
        self.assertEqual(res().status_code, 200)

        # Location update failed
        res = go(self.app.post, '/registerLocation', query_string={'user_name': self.user, 'location': {'latitude': '0.000','longitude': '0.000'}})
        self.server.reply({'n': 0, 'ok': 1.0})
        self.assertEqual(res().status_code, 400)

    def test_lookup(self):
        ''' Test 4: /lookup endpoint'''

        # No friend/user name provided
        res = go(self.app.get,'/lookup', query_string={'user_name': '', 'friend_name': ''})
        self.assertEqual(res().status_code , 400)

        # No such user
        res = go(self.app.get,'/lookup', query_string={'user_name': self.user, 'friend_name': 'n/a'})
        self.server.reply(cursor={'id': 0, 'firstBatch': []})
        self.assertEqual(res().status_code , 400)

        # Requested user not in friend list
        res = go(self.app.get,'/lookup', query_string={'user_name': self.user, 'friend_name': 'not_a_friend'})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': 'dont_look_at_me_rn', 'friendsList': ['a_friend']}]})
        self.assertEqual(res().status_code , 401)

        # Look up friend who is not sharing location
        res = go(self.app.get,'/lookup', query_string={'user_name': self.user, 'friend_name': 'dont_look_at_me_rn'})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': self.user, 'friendsList': ['dont_look_at_me_rn']}]})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': 'dont_look_at_me_rn', 'location_sharing': False}]})
        self.assertEqual(res().status_code , 401)

        # Look up friend's location successfully
        res = go(self.app.get, '/lookup', query_string={'user_name': self.user, 'friend_name': 'look_at_me'})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': self.user, 'friendsList': ['look_at_me']}]})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': 'look_at_me', 'location_sharing': True}]})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': 'look_at_me', 'location_sharing': True, 'location': {'x': 4, 'y': 4}}]})
        response = res()
        self.assertEqual(response.status_code, 200)
        self.assertEqual(json.loads(response.data)['x'], 4)
        self.assertEqual(json.loads(response.data)['y'], 4)

        # Look up friend's location that does not exist
        res = go(self.app.get, '/lookup', query_string={'user_name': self.user, 'friend_name': 'i_dont_exist'})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': self.user, 'friendsList': ['i_dont_exist']}]})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': 'look_at_me', 'location_sharing': True}]})
        self.server.reply(cursor={'id': 0, 'firstBatch': []})
        response = res()
        self.assertEqual(response.status_code, 400)


    def test_toggle(self):
        '''Test 6: /toggle endpoint'''

        # No username provided
        res = go(self.app.get, '/toggle', query_string={'user_name': ''})
        self.assertEqual(res().status_code, 400)

        # User doesn't exist
        res = go(self.app.get, '/toggle', query_string={'user_name': 'i_dont_exist'})
        self.server.reply(cursor={'id': 0, 'firstBatch': []})
        self.assertEqual(res().status_code, 400)

        # Untoggle
        res = go(self.app.get, '/toggle', query_string={'user_name': self.user})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': 'toggle_me', 'location_sharing': False}]})
        self.server.reply({'n': 1, 'ok': 1.0})
        self.assertEqual(res().status_code, 200)


if __name__ == '__main__':
    unittest.main()
