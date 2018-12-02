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
        # TODO: Warnings are raised about not killing subprocess. I'm not sure why
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
        
        # Username
        user = 'user_{}'.format(time.time())

        # Add new user to database
        rv =  self.db_test.add_user(user)
        verify = self.db_verify['User'].find_one({'user': user})
        self.assertEqual(verify['user'], user)
        self.assertEqual(verify['location_sharing'], False)      # Default value
        self.assertEqual(verify['friends_list'], [])              # Default value
        self.assertEqual(rv, True)

        # Add same user again
        rv = self.db_test.add_user(user)
        self.assertEqual(rv, False)


    def test_friend_list(self):
        """ 
            Test 2:
            Verify that we can add, delete and retrieve friends from friend list without
            duplicates.
        """

        # Username and friend
        user = 'user_{}'.format(time.time())
        friend0 = 'friend_{}'.format(time.time())
        friend1= 'friend_{}'.format(time.time())

        # Add initial user to database
        rv = self.db_test.add_user(user)
        rv = self.db_test.get_friends_list(user)

        # Add new friend
        rv = self.db_test.add_friend(user, friend0)
        result = self.db_verify['User'].find_one({'user': user})
        self.assertEqual(result['friends_list'],[friend0] )
        self.assertEqual(rv, True)

        # Add same friend. Make sure we don't duplicate
        rv = self.db_test.add_friend(user, friend0)
        result = self.db_verify['User'].find_one({'user': user})
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
        user0 = 'user_{}'.format(time.time())
        user1 = 'friend_{}'.format(time.time())

        # Location and building
        location_user0 = {'x': 0, 'y': 0}
        floor = {'building': 'MooreHall', 'floor': '1', 'vertices': [(0,0), (100,0), (0,100), (100,100)]}
        indoor_loc_user0 = {'building': 'MooreHall', 'floor': '1', 'x': 16, 'y': 82}
        room_user0 = 1009

        # Add initial user to database
        self.db_test.add_user(user0)
        self.db_test.add_user(user1)
        self.db_test.add_friend(user1,user0)

        # Set location for user0
        rv = self.db_test.set_location(user0,location_user0)
        result = self.db_verify['User'].find_one({'user': user0})
        self.assertEqual(rv, True)
        self.assertEqual(result['location'], location_user0)

        # Set indoor location for user0
        rv = self.db_test.register_indoor(user0,indoor_loc_user0, room_user0)
        result = self.db_verify['User'].find_one({'user': user0})
        self.assertEqual(rv, True)
        self.assertEqual(result['indoor_location'], indoor_loc_user0)
        
        # Get user0's location with user0 not sharing location
        rv = self.db_test.get_location(user0)
        self.assertEqual(rv, None)

        # Toggle user0's location sharing settings
        rv_toggle = self.db_test.toggle(user0)
        result = self.db_verify['User'].find_one({'user': user0})
        self.assertEqual(rv_toggle, True)
        self.assertEqual(result['location_sharing'], True)        # Default was False

        # Get user0's location with user0 sharing location
        rv = self.db_test.get_location(user0)
        user0_loc = {'outdoor_location': location_user0, 'indoor_location': indoor_loc_user0}
        self.assertEqual(rv, user0_loc)

    def test_get_building(self):
        """ 
            Test 4:
            Verify that we can add building floors and get building
        """

        # Building
        building = 'MooreHall'
        floor = '1'
        vertices = [[0,0], [100,0], [0,100], [100,100]]
        floors = [{'floor': '1', 'vertices': [[0,0], [100,0], [0,100], [100,100]]}]

        # Add building to database
        rv = self.db_test.add_floor(building, floor, vertices)
        self.assertEqual(rv, True)
        verify = self.db_verify['Building'].find_one({'building_name': building})
        self.assertEqual(verify['building_name'], building)
        self.assertEqual(verify['floor'], floor)
        self.assertEqual(verify['vertices'], vertices)
   
        # Get floors of a building
        rv = self.db_test.get_building(building)
        self.assertEqual(rv[0]['floor'], floors[0]['floor'])
        self.assertEqual(rv[0]['vertices'], floors[0]['vertices'])

if __name__ == '__main__':
    unittest.main()

