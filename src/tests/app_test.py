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
        self.email = 'user@email.ucla'
        self.building = 'test_building'
        self.server = MockupDB(auto_ismaster={"maxWireVersion": 6})
        self.server.run()
        self.app = app.create_test_app(self.server.uri).test_client()

    def tearDown(self):
        ''' Take down test fixtures '''
        self.server.stop()

    def test_addUser(self):
        '''Test 1: /addUser endpoint'''

        # No username or email provided
        res = go(self.app.get, '/addUser', query_string={'user_name': '', 'user_email': ''})
        self.assertEqual(res().status_code, 400)

        # User doesn't exist
        res = go(self.app.get, '/addUser', query_string={'user_name': self.user, 'user_email': self.email})
        self.server.reply(cursor={'id': 0, 'firstBatch': [None]})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'user': self.user, 'email': self.email}]})
        self.assertEqual(res().status_code, 200)

        # User was added twice
        res = go(self.app.get, '/addUser', query_string={'user_name': self.user, 'user_email': self.email})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'user': self.user, 'email': self.email}]})
        self.assertEqual(res().status_code, 400)

    def test_addFriend(self):
        ''' Test 2: /addFriend endpoint'''

        # No username/friend provided
        res = go(self.app.get, '/addFriend', query_string={'user_email': '', 'friend_email': ''})
        self.assertEqual(res().status_code, 400)

        # Friend was added successfully
        res = go(self.app.get, '/addFriend', query_string={'user_email': self.email, 'friend_email': 'friend_test@ucla.edu'})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'email': self.email, 'friends_list': []}]})
        self.server.reply({'n': 1, 'nModified': 1, 'ok': 1.0, 'updatedExisting': True})
        self.assertEqual(res().status_code, 200)


        # Add friend to non-existent user
        res = go(self.app.get, '/addFriend', query_string={'user_email': 'not_a_user', 'friend_email': 'friend_test'})
        self.server.reply(cursor={'id': 0, 'firstBatch': []})
        self.assertEqual(res().status_code, 400)

    def test_deleteFriend(self):
        ''' Test 3: /deleteFriend endpoint'''

        # Bad arguments
        res = go(self.app.get, '/deleteFriend', query_string={'user_email': '', 'friend_email': ''})
        self.assertEqual(res().status_code, 400)

        # Friend was deleted successfully
        res = go(self.app.get, '/deleteFriend', query_string={'user_email': self.email, 'friend_email': 'delete_me@ucla.edu'})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'email': self.email, 'friends_list': ['delete_me@ucla.edu']}]})
        self.server.reply({'n': 1, 'ok': 1.0})
        self.assertEqual(res().status_code, 200)

        # Friend does not exist
        res = go(self.app.get, '/deleteFriend', query_string=({'user_email': self.email, 'friend_email': 'i_dont_exist'}))
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'email': self.email, 'friends_list': ['i_do_exist']}]})
        self.assertEqual(res().status_code, 400)

    def test_registerLocation(self):
        ''' Test 4: /registerLocation endpoint'''

        # Location update successful
        res = go(self.app.post, '/registerLocation', data=json.dumps({'user_email': self.email, 'location': {'latitude': '0.000','longitude': '0.000'}}))
        self.server.reply({'n': 1, 'nModified': 1, 'ok': 1.0, 'updatedExisting': True})
        self.assertEqual(res().status_code, 200)
        
        # Missing user email
        res = go(self.app.post, '/registerLocation', data=json.dumps({'user_email': '', 'location': {'latitude': '0.000','longitude': '0.000'}}))
        self.assertEqual(res().status_code, 400)
        
        # Missing location
        res = go(self.app.post, '/registerLocation', data=json.dumps({'user_email': self.email}))
        self.assertEqual(res().status_code, 400)

    def test_lookup(self):
        ''' Test 5: /lookup endpoint'''

        # No friend/user name provided
        res = go(self.app.get,'/lookup', query_string={'user_email': '', 'friend_email': ''})
        self.assertEqual(res().status_code , 400)

        # No such user
        res = go(self.app.get,'/lookup', query_string={'user_email': self.user, 'friend_email': 'n/a'})
        self.server.reply(cursor={'id': 0, 'firstBatch': []})
        self.assertEqual(res().status_code , 400)

        # Requested user not in friend list
        res = go(self.app.get,'/lookup', query_string={'user_email': self.email, 'friend_email': 'not_a_friend'})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'email': self.email, 'friends_list': ['a_friend']}]})
        self.assertEqual(res().status_code , 400)

        # Look up friend who is not sharing location
        res = go(self.app.get,'/lookup', query_string={'user_email': self.email, 'friend_email': 'dont_look_at_me_rn'})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'email': self.email, 'friends_list': ['dont_look_at_me_rn']}]})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'email': 'dont_look_at_me_rn', 'location_sharing': False}]})
        self.assertEqual(res().status_code , 401)

        # Look up friend's location successfully
        res = go(self.app.get, '/lookup', query_string={'user_email': self.email, 'friend_email': 'look_at_me'})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'email': self.email, 'friends_list': ['look_at_me']}]})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'email': 'look_at_me', 'location_sharing': True, 'location': {'x': 4, 'y': 4}, 'indoor_location': {'building': 'MooreHall', 'floor': '1', 'x': 16, 'y': 82, 'room': 1009}, 'last_seen_indoor': 0.0}]})
        outdoor = {'x': 4, 'y': 4}
        indoor = {'building': 'MooreHall', 'floor': '1', 'x': 16, 'y': 82, 'room': 1009}
        response = res()
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json()['location']['outdoor_location'], outdoor)
        self.assertEqual(response.get_json()['location']['indoor_location'], indoor)
        self.assertTrue(response.get_json()['minutes_ago_indoor'])

    def test_toggle(self):
        '''Test 6: /toggle endpoint'''

        # No username provided
        res = go(self.app.get, '/toggle', query_string={'user_email': ''})
        self.assertEqual(res().status_code, 400)

        # User doesn't exist
        res = go(self.app.get, '/toggle', query_string={'user_email': 'i_dont_exist'})
        self.server.reply(cursor={'id': 0, 'firstBatch': []})
        self.assertEqual(res().status_code, 400)

        # Untoggle
        res = go(self.app.get, '/toggle', query_string={'user_email': self.email})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'email': 'toggle_me', 'location_sharing': False}]})
        self.server.reply({'n': 1, 'ok': 1.0})
        self.assertEqual(res().status_code, 200)

    def test_registerIndoor(self):
        '''Test 7: /registerIndoor endpoint'''

        location=json.dumps({'building': 'MooreHall','floor': '1', 'x': 10, 'y': 10})
        
        # Missing user email
        res = go(self.app.post, '/registerIndoor', data=json.dumps({'user_email': '', 'location': location}))
        self.assertEqual(res().status_code, 400)
        
        # Missing location
        res = go(self.app.post, '/registerIndoor', data=json.dumps({'user_email': self.email, 'location': {}}))
        self.assertEqual(res().status_code, 400)
        
        '''
        # Register location successfully
        res = go(self.app.post, '/registerIndoor', json=location, data=json.dumps({'user_email': self.email, 'location': {'building': 'MooreHall', 'floor': '1', 'x': 16, 'y': 82}}))
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'email': self.email, 'location_sharing': True, 'indoor_location': {'building': 'MooreHall', 'floor': '1', 'x': 16, 'y': 82, 'room': 1009}}]})
        self.server.reply({'n': 1, 'nModified': 1, 'ok': 1.0, 'updatedExisting': True})
        self.assertEqual(res().status_code, 200)
        '''
    
    def test_getFriends(self):
        '''Test 8: /getFriends endpoint'''

        # No username provided
        res = go(self.app.get, '/getFriends', query_string={'user_email': ''})
        self.assertEqual(res().status_code, 400)
        
        # User doesn't exist
        res = go(self.app.get, '/getFriends', query_string={'user_email': 'i_dont_exist'})
        self.server.reply(cursor={'id': 0, 'firstBatch': []})
        self.assertEqual(res().status_code, 400)
        
        # User exists and has friends
        res = go(self.app.get, '/getFriends', query_string={'user_email': self.email})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'email': self.email, 'friends_list':['friend_1']}]})
        self.assertEqual(res().status_code, 200)
       
    def test_getBuildingMetadata(self):
        '''Test 9: /getBuildingMetadata endpoint'''
        
        # No building name provided
        res = go(self.app.get, '/getBuildingMetadata', query_string={'building_name': ''})
        self.assertEqual(res().status_code, 400)
        
        # Building not in database
        res = go(self.app.get, '/getBuildingMetadata', query_string={'building_name': self.building})
        self.server.reply(cursor={'id': 0, 'firstBatch': []})
        self.assertEqual(res().status_code, 401)
                
        # Get number of floor plans in db for building
        res = go(self.app.get, '/getBuildingMetadata', query_string={'building_name': self.building})
        self.server.reply(cursor={'id': 0, 
                                  'firstBatch': [{'building_name': self.building,
                                                  'location': {'longitude': 0.0, 'latitude': 0.0}}]})
        self.server.reply(cursor={'id': 0, 
                                  'firstBatch': [{'building_name': self.building,
                                                  'location': {'longitude': 0.0, 'latitude': 0.0},
                                                  'floor': '1', 
                                                  'vertices': [(0,0), (100,0), (0,100), (100,100)]}]
                                 }
                         )
        self.assertEqual(res().status_code, 200)
        self.assertEqual(res().get_json()['number_of_floors'], 1)
        self.assertEqual(res().get_json()['location'], {'longitude': 0.0, 'latitude': 0.0})
        
    def test_modal_to_pixel(self):
        '''Test 10: modal_to_pixel function'''
        
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

    def test_getName(self):
        '''Test 11: /getName endpoint'''
    
        # No email provided
        res = go(self.app.get, '/getName', query_string={'email': ''})
        self.assertEqual(res().status_code, 400)
        
        # No user
        res = go(self.app.get, '/getName', query_string={'email': 'not_exist@ucla.edu'})
        self.server.reply(cursor={'id': 0, 'firstBatch': []})
        self.assertEqual(res().status_code, 400)
        
        # User exists
        res = go(self.app.get, '/getName', query_string={'email': self.email})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'user': self.user, 'email': self.email}]})
        self.assertEqual(res().status_code, 200)
        
    def test_get_building_by_radius(self):
        '''Test 12: /getBuildingByRadius endpoint'''
        
        # Missing location
        res = go(self.app.get, '/getBuildingByRadius', query_string={'radius': 5.0})
        self.assertEqual(res().status_code, 400)
        
        '''
        # Some building within radius
        res = go(self.app.get, '/getBuildingByRadius', query_string={'longitude': 1.0, 'latitude': 1.0, 'radius': 5.0})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'building_name': 'a_building', 'location': {'longitude': 2.0, 'latitude': 2.0}}]})
        self.assertEqual(res().status_code, 200)
        
        # No building within radius
        res = go(self.app.get, '/getBuildingByRadius', query_string={'longitude': 1.0, 'latitude': 1.0, 'radius': 5.0})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'building_name': 'a_building', 'location': {'longitude': 10.0, 'latitude': 10.0}}]})
        self.assertEqual(res().status_code, 400)
        '''
        
    def test_add_building(self):
        '''Test 13: /addBuilding endpoint'''
            
        # Building already exist
        name = 'my_new_building'
        longitude = 1.0
        latitude = 10.0
        res = go(self.app.get, '/addBuilding', query_string={'building_name': name, 'longitude': longitude, 'latitude': latitude})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'building_name': name, 'location': {'longitude': longitude, 'latitude': latitude}}]})
        self.assertEqual(res().status_code, 401)
        
        # Added successfully
        name = 'my_new_building'
        longitude = 1.0
        latitude = 10.0
        res = go(self.app.get, '/addBuilding', query_string={'building_name': name, 'longitude': longitude, 'latitude': latitude})
        self.server.reply(cursor={'id': 0, 'firstBatch': [None]})
        self.server.reply(cursor={'id': 0, 'firstBatch': [{'building_name': name, 'location': {'longitude': longitude, 'latitude': latitude}}]})
        self.assertEqual(res().status_code, 200)
        
        # Missing arguments
        res = go(self.app.get, '/getBuildingByRadius', query_string={'building_name': 'a_building'})
        self.assertEqual(res().status_code, 400)
        
    def test_getFloorImage(self):
        '''Test 14: /getFloorImage endpoint'''
        
        pass
        
    def test_addFloor(self):
        '''Test 15: /addFloor endpoint'''
        
        pass

if __name__ == '__main__':
    unittest.main()
