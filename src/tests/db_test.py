import unittest
import time
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure
import os, subprocess

import context
from db import Db

PATH_TO_MONGOD = '/usr/local/bin/mongod'


class DbTest(unittest.TestCase):
    '''
        Unit test for db.py. 
    '''
    def setUp(self):
        """ Set up test fixtures """

        # Set up mongod daemon
        self.devnull = open(os.devnull,'w')
        self.mongod = subprocess.Popen(PATH_TO_MONGOD,stdout=self.devnull) 
        
        # Create Db instance which we will test
        uri = 'mongodb://localhost:27017'
        self.db_test = Db(uri,'wya_test')

        # Create a second interface to the same collection to verify 
        self.db_verify = MongoClient(uri)['wya_test']


    def tearDown(self):
        """ Take down test fixtures """
        # Delete all data we just added
        self.db_verify.User.drop()
        self.db_verify.Building.drop()
        self.mongod.kill()
        self.devnull.close()


    def test_add_user(self):
        """ Test 1
            Tests that we can add users with no duplicates 
        """
        
        # User
        user = 'user_{}'.format(time.time())
        email = 'my_email@ucla.edu'

        # Add new user to database
        rv =  self.db_test.add_user(user, email)
        verify = self.db_verify['User'].find_one({'email': email})
        self.assertEqual(verify['user'], user)
        self.assertEqual(verify['email'], email)
        self.assertEqual(verify['location_sharing'], False)      # Default value
        self.assertEqual(verify['friends_list'], [])              # Default value
        self.assertEqual(rv, True)

        # Add same user again
        rv = self.db_test.add_user(user, email)
        self.assertEqual(rv, False)


    def test_friend_list(self):
        """ 
            Test 2:
            Verify that we can add, delete and retrieve friends from friend list without
            duplicates.
        """

        # Username and friend
        user_name = 'the_user'
        user = 'user_{}@ucla.edu'.format(time.time())
        friend0_name = 'Zero'
        friend0 = 'friend_{}@ucla.edu'.format(time.time())
        friend1_name = 'One'
        friend1= 'friend_{}@ucla.edu'.format(time.time())

        # Add friend to non_user
        rv = self.db_test.add_friend(user, friend0)
        self.assertEqual(rv, False)
        
        # Add initial user to database
        rv = self.db_test.add_user(user_name, user)
        rv = self.db_test.add_user(friend0_name, friend0)
        rv = self.db_test.add_user(friend1_name, friend1)
        rv = self.db_test.get_friends_list(user)

        # Add new friend
        rv = self.db_test.add_friend(user, friend0)
        result = self.db_verify['User'].find_one({'email': user})
        self.assertEqual(rv, True)
        self.assertEqual(result['friends_list'],[friend0] )
        
        # Add friend who isn't a user
        rv = self.db_test.add_friend(user, 'not_a_user@ucla.edu')
        self.assertEqual(rv, False)

        # Add same friend. Make sure we don't duplicate
        rv = self.db_test.add_friend(user, friend0)
        result = self.db_verify['User'].find_one({'email': user})
        self.assertEqual(len(result['friends_list']), 1 )
        self.assertEqual(rv, False)

        # Get friend list
        self.db_test.add_friend(user, friend1)              # Add second friend
        result = self.db_test.get_friends_list(user)
        self.assertEqual(result, [friend0,friend1] )

        # Delete friend
        result = self.db_test.delete_friend(user, friend1)
        friend_list = self.db_test.get_friends_list(user)
        self.assertEqual(friend_list, [friend0] )           # Make sure it was deleted
        self.assertEqual(result, True ) 

        # Delete same friend twice
        result = self.db_test.delete_friend(user, friend1)
        friend_list = self.db_test.get_friends_list(user)
        self.assertEqual(friend_list, [friend0] ) 
        self.assertEqual(result, False ) 

        # Try and delete from an empty friend list
        self.db_test.delete_friend(user, friend0)
        result = self.db_test.delete_friend(user, 'i_dont_exist')   # Try to delete from empty list
        friend_list = self.db_test.get_friends_list(user)
        self.assertEqual(friend_list, [] )
        self.assertEqual(result, False ) 
 
    def test_location(self):
        """ 
            Test 3:
            Verify that we can set and get locations accuractely and according to location
            sharing settings (i.e. toggle function)
        """

        # Username and friend
        name0 = 'Zero'
        user0 = 'user_{}@ucla.edu'.format(time.time())
        name1 = 'One'
        user1 = 'friend_{}@ucla.edu'.format(time.time())

        # Location and building
        location_user0 = {'x': 0, 'y': 0}
        indoor_loc_user0 = {'building': 'MooreHall', 'floor': '1', 'x': 16, 'y': 82}
        room_user0 = 1009
        last_seen = 1235678.0
        indoor_res = {'building': 'MooreHall', 'floor': '1', 'x': 16, 'y': 82, 'room': 1009}

        # Add initial user to database
        self.db_test.add_user(name0, user0)
        self.db_test.add_user(name1, user1)
        self.db_test.add_friend(user1,user0)

        # Set location for user0
        rv = self.db_test.set_location(user0,location_user0)
        result = self.db_verify['User'].find_one({'email': user0})
        self.assertEqual(rv, True)
        self.assertEqual(result['location'], location_user0)

        # Set indoor location for user0
        rv = self.db_test.register_indoor(user0, indoor_loc_user0, room_user0, last_seen)
        result = self.db_verify['User'].find_one({'email': user0})
        self.assertEqual(rv, True)
        self.assertEqual(result['indoor_location'], indoor_res)
        self.assertEqual(result['last_seen_indoor'], last_seen)
        
        # Get user0's location with user0 not sharing location
        rv = self.db_test.get_location(user0)
        self.assertEqual(rv, (None, None))

        # Toggle user0's location sharing settings
        rv_toggle = self.db_test.toggle(user0)
        result = self.db_verify['User'].find_one({'email': user0})
        self.assertEqual(rv_toggle, True)
        self.assertEqual(result['location_sharing'], True)        # Default was False

        # Get user0's location with user0 sharing location
        rv = self.db_test.get_location(user0)
        user0_loc = {'outdoor_location': location_user0, 'indoor_location': indoor_res}
        self.assertEqual(rv, (user0_loc, last_seen))
        
        # Set location for non-user
        rv = self.db_test.set_location('non-user',location_user0)
        self.assertEqual(rv, False)
        
        # Register indoor location for non-user
        rv = self.db_test.register_indoor('not_exist',indoor_loc_user0, room_user0, last_seen)
        self.assertEqual(rv, False)

    def test_building(self):
        """ 
            Test 4:
            Verify that we can add building, building floors and get building
        """

        # Building
        building = 'MooreHall'
        location = {'longitude': 10.0, 'latitude': 1.0}
        floor = '1'
        vertices = [[0,0], [100,0], [0,100], [100,100]]
        floors = [{'floor': '1', 'vertices': [[0,0], [100,0], [0,100], [100,100]]}]

        # Add building to database
        rv = self.db_test.add_building(building, location)
        self.assertEqual(rv, True)
        verify = self.db_verify['Building'].find_one({'building_name': building})
        self.assertEqual(verify['building_name'], building)
        self.assertEqual(verify['location'], location)
        
        # Add existing building
        rv = self.db_test.add_building(building, location)
        self.assertEqual(rv, False)
        
        # Add floor to building
        rv = self.db_test.add_floor(building, floor, vertices)
        verify = self.db_verify['Building'].find_one({'building_name': building, 'floor': floor})
        self.assertEqual(rv, True)
        self.assertEqual(verify['vertices'], vertices)
        
        # Add floor to non-existing building
        rv = self.db_test.add_floor("not_exist", floor, vertices)
        self.assertEqual(rv, False)
   
        # Get floors of a building
        rv = self.db_test.get_building(building)
        self.assertEqual(rv[0]['floor'], floors[0]['floor'])
        self.assertEqual(rv[0]['vertices'], floors[0]['vertices'])
        
        # Get building location
        rv = self.db_test.get_building_location(building)
        self.assertEqual(rv, location)
        
        # Get location of non existing building
        rv = self.db_test.get_building_location('not_exist')
        self.assertEqual(rv, None)

    def test_get_name(self):
        """ 
            Test 5:
            Verify that we can get name given email
        """
        # User
        user = 'user_{}'.format(time.time())
        email = 'my_email@ucla.edu'
        
        # No entry with given email in database
        rv = self.db_test.get_name(email)
        self.assertEqual(rv, None)

        # Add user to database
        rv = self.db_test.add_user(user, email)

        # Get user name from email
        rv = self.db_test.get_name(email)
        self.assertEqual(rv, user)        

if __name__ == '__main__':
    unittest.main()

