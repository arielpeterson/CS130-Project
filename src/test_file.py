from mockupdb import *
import unittest

# Our own database class using PyMongo
from db import Db

class ModifyUserTest(unittest.TestCase):
	def setUp(self):
		self.server = MockupDB(auto_ismaster={"maxWireVersion": 6})
        self.server.run()

        # Replace pymongo connection url to use MockupDB
        self.database = Db(self.server.uri)

	def tearDown(self):
		self.server.stop()

	def test_add_valid_friend_valid_user(self):
		pass
		# Pass a method and its arguments to the go function
		add_user_query = go(self.database.add_friend, 'Zach', 'Brad')

		request = self.server.receives()

		# Return value placed in query
		request.reply()

		self.assertEqual()

	def test_add_invalid_friend_valid_user(self):
		pass

	def test_add_valid_friend_invalid_user(self):
		pass

	def test_add_invalid_friend_invalid_user(self):
		pass

	def test_delete_friend(self):
		pass
