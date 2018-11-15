import os
import requests
import json
import time
import unittest

import pymongo

url = 'http://localhost:5000'

user = 'test_{}'.format(int(time.time()))

class AppTest(unittest.TestCase):
    def test_app(self):
        # Test 1: Add new user
        res = requests.get(os.path.join(url, 'addUser'), params=dict(user_name=user))
        self.assertEqual(res.status_code, 200)

        # Add same user again
        res = requests.get(os.path.join(url, 'addUser'), params=dict(user_name=user))
        self.assertEqual(res.status_code , 400)

        # Test 2: Add Friend
        res = requests.get(os.path.join(url, 'addFriend'), params=dict(user_name=user, friend_name='friend_test'))
        self.assertEqual(res.status_code , 200)

        # Add friend to non-existent user
        res = requests.get(os.path.join(url, 'addFriend'), params=dict(user_name='no_user', friend_name='friend_test'))
        self.assertEqual(res.status_code , 400)

        # Test 3: Delete Friend
        res = requests.get(os.path.join(url, 'deleteFriend'), params=dict(user_name=user, friend_name='friend_test'))
        self.assertEqual(res.status_code , 200)

        # Friend already removed
        res = requests.get(os.path.join(url, 'deleteFriend'), params=dict(user_name=user, friend_name='friend_test'))
        self.assertEqual(res.status_code , 400)

        # Add back
        res = requests.get(os.path.join(url, 'addFriend'), params=dict(user_name=user, friend_name='friend_test'))

        # Test 4: Register Location
        res = requests.post(os.path.join(url, 'registerLocation'), params=dict(user_name='friend_test'), json={'x':4, 'y':4})
        self.assertEqual(res.status_code , 200)

        res = requests.post(os.path.join(url, 'registerLocation'), params=dict(user_name='zach_test3'), json={'x':1, 'y':2})
        self.assertEqual(res.status_code , 400)

        # Test 5: Lookup
        res = requests.get(os.path.join(url, 'lookup'), params=dict(user_name=user, friend_name='friend_test'))
        self.assertEqual(res.status_code , 200)
        self.assertEqual(json.loads(res.content)['x'] , 4)
        self.assertEqual(json.loads(res.content)['y'] , 4)

        # add not_friend
        res = requests.get(os.path.join(url, 'addUser'), params=dict(user_name='not_friend'))

        # Access denied
        res = requests.get(os.path.join(url, 'lookup'), params=dict(user_name=user, friend_name='not_friend'))
        self.assertEqual(res.status_code , 401)

        # No such user
        res = requests.get(os.path.join(url, 'lookup'), params=dict(user_name='zach_test3', friend_name='zach_test'))
        self.assertEqual(res.status_code , 400)

        # Test 6: Toggle
        res = requests.get(os.path.join(url, 'toggle'), params=dict(user_name=user))
        self.assertEqual(res.status_code , 200)

        # Make sure can no longer access location
        res = requests.get(os.path.join(url, 'lookup'), params=dict(user_name=user, friend_name='friend_test'))
        self.assertEqual(res.status_code , 401)

        # Untoggle
        res = requests.get(os.path.join(url, 'toggle'), params=dict(user_name=user))
        self.assertEqual(res.status_code , 200)

if __name__ == '__main__':
    unittest.main()

