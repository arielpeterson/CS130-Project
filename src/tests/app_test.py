import json
import unittest
from mockupdb import MockupDB, go
from context import app
import app as my_app

class AppTest(unittest.TestCase):
    '''
        Unit test for app.py. 
        Uses mockupdb to act as the database.
        Each endpoint is tested in a seperate method.
    '''

    def setUp(self):
        ''' Set up test fixtures '''
        self.user = 'i_am_a_user'
        self.building = 'test_building'
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

        # Friend was added successfully
        res = go(self.app.get, '/addFriend', query_string={'user_name': self.user, 'friend_name': 'friend_test'})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': self.user, 'friends_list': []}]})
        self.server.reply({'n': 1, 'nModified': 1, 'ok': 1.0, 'updatedExisting': True})
        self.assertEqual(res().status_code, 200)


        # Add friend to non-existent user
        res = go(self.app.get, '/addFriend', query_string={'user_name': 'not_a_user', 'friend_name': 'friend_test'})
        self.server.reply(cursor={'id': 0, 'firstBatch': []})
        self.assertEqual(res().status_code, 400)

    def test_deleteFriend(self):
        ''' Test 3: /deleteFriend endpoint'''

        # Bad arguments
        res = go(self.app.get, '/deleteFriend', query_string={'user_name': '', 'friend_name': ''})
        self.assertEqual(res().status_code, 400)

        # Friend was deleted successfully
        res = go(self.app.get, '/deleteFriend', query_string={'user_name': self.user, 'friend_name': 'delete_me'})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': self.user, 'friends_list': ['delete_me']}]})
        self.server.reply({'n': 1, 'ok': 1.0})
        self.assertEqual(res().status_code, 200)

        # Friend does not exist
        res = go(self.app.get, '/deleteFriend', query_string={'user_name': self.user, 'friend_name': 'i_dont_exist'})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': self.user, 'friends_list': ['i_do_exist']}]})
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
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': self.user, 'friends_list': ['a_friend']}]})
        self.assertEqual(res().status_code , 400)

        # Look up friend who is not sharing location
        res = go(self.app.get,'/lookup', query_string={'user_name': self.user, 'friend_name': 'dont_look_at_me_rn'})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': self.user, 'friends_list': ['dont_look_at_me_rn']}]})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': 'dont_look_at_me_rn', 'location_sharing': False}]})
        self.assertEqual(res().status_code , 401)

        # Look up friend's location successfully
        res = go(self.app.get, '/lookup', query_string={'user_name': self.user, 'friend_name': 'look_at_me'})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': self.user, 'friends_list': ['look_at_me']}]})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'User': 'look_at_me', 'location_sharing': True, 'location': {'x': 4, 'y': 4}}]})
        response = res()
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json()['x'], 4)
        self.assertEqual(response.get_json()['y'], 4)

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

    def test_registerIndoor(self):
        pass
        '''
        # Location update successful
        res = go(self.app.post, '/registerIndoor', query_string={'user_name': self.user, 'location': {'building': '0.000','floor': '0.000', 'x': 10, 'y': 10}})
        self.server.reply({'n': 1, 'ok': 1.0})
        self.assertEqual(res().status_code, 200)

        # Location update failed
        res = go(self.app.post, '/registerIndoor', query_string={'user_name': self.user, 'location': {'latitude': '0.000','longitude': '0.000'}})
        self.server.reply({'n': 0, 'ok': 1.0})
        self.assertEqual(res().status_code, 400) 
        '''       
    
    def test_getFriends(self):
        # No username provided
        res = go(self.app.get, '/getFriends', query_string={'user_name': ''})
        self.assertEqual(res().status_code, 400)
        
        # User doesn't exist
        res = go(self.app.get, '/getFriends', query_string={'user_name': 'i_dont_exist'})
        self.server.reply(cursor={'id': 0, 'firstBatch': []})
        self.assertEqual(res().status_code, 400)
        
        # User exists and has friends
        res = go(self.app.get, '/getFriends', query_string={'user_name': self.user})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'user_name': self.user, 'friends_list':['friend_1']}]})
        self.assertEqual(res().status_code, 200)
    
    def test_addFloor(self):
        pass
    
    def test_getBuildingMetadata(self):
        # No building name provided
        res = go(self.app.get, '/getBuildingMetadata', query_string={'building_name': ''})
        self.assertEqual(res().status_code, 400)
        
        # Get number of floor plans in db for building
        res = go(self.app.get, '/getBuildingMetadata', query_string={'building_name': self.building})
        self.server.reply(cursor={'id': 0, 
                                  'firstBatch': [{'building_name': self.building, 
                                                  'floor': '1', 
                                                  'vertices': [(0,0), (100,0), (0,100), (100,100)]}]
                                 }
                         )
        self.assertEqual(res().status_code, 200)
        self.assertEqual(res().get_json()['floors'], 1)
    
    def test_getFloorImage(self):
        pass
        
    def test_modal_to_pixel(self):
        '''
        Using default shape=[100, 100]
        Condition evaluation: TTFF
        Branch coverage: 50%
        '''
        res = go(my_app.model_to_pixel, -1, -1)
        self.assertEqual(res(), (0, 0))
        
        '''
        Using shape=[500, 500]
        Condition evaluation: TTFF
        Branch coverage: 100%
        '''
        res = go(my_app.model_to_pixel, 101, 101, [500, 500])
        self.assertEqual(res(), (500, 500))

if __name__ == '__main__':
    unittest.main()
