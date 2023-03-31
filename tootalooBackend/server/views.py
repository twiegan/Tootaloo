from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_exempt
import certifi
import environ

# Initialize environment variables .env inside of tootalooBackend/
env = environ.Env()
environ.Env.read_env()

# Create your views here.
# def index(request):
#     return HttpResponse("<h1>Hello and welcome to <u>Tootaloo</u></h1>")


import pymongo
import json
from bson import json_util
from bson.json_util import dumps
from bson.objectid import ObjectId

# from .models import Restroom


#PyMongo client
client = pymongo.MongoClient(env('MONGODB_CONNECTION_STRING'), tlsCAFile=certifi.where(), serverSelectionTimeoutMS=5000)



def buildings(request):

	print("got GET request for buildings")

	db = client['tootaloo']
	buildings_collection = db['buildings']

	buildings = buildings_collection.find()

	resp = HttpResponse(dumps(buildings, sort_keys=True, indent=4, default=json_util.default))
	resp['Content-Type'] = 'application/json'
	
	return resp


def ratingsByIds(request):

	print("GET request received: ratings")

	ids = request.GET.getlist('ids[]', '')
	print("ids: ", ids)

	db = client['tootaloo']
	ratings_collection = db['ratings']

	ratings_data = ratings_collection.find({"_id":{"$in": [ObjectId(id) for id in ids]}})

	ratings = []
	for rating in ratings_data:
		ratings.append(rating)

	resp = HttpResponse(dumps(ratings, sort_keys=True, indent=4, default=json_util.default))
	resp['Content-Type'] = 'application/json'
	
	return resp


def restroomsByBuildingAndFloor(request):

	# TODO: refactor as restroomsByBuildingAndOrFloor

	'''Endpoint accepts 2 query params (building && floor) used to search db'''

	print("GET request received: restrooms")

	# Connect to db and search restrooms based on query params
	db = client['tootaloo']
	restrooms_collection = db['restrooms']

	building = request.GET.get('building', '')
	floor = request.GET.get('floor', '')

	if building == "" and floor != "":
		restrooms = restrooms_collection.find({'floor': int(floor)})
	elif building != "" and floor == "":
		restrooms = restrooms_collection.find({'building': building})
	elif building != "" and floor != "":
		restrooms = restrooms_collection.find({'building': building, 'floor': int(floor)})
	else:
		return None

	# Return response
	resp = HttpResponse(dumps(restrooms, sort_keys=True, indent=4, default=json_util.default))
	resp['Content-Type'] = 'application/json'
	
	return resp


def userByUsername(request):

	print("GET request received: userByUsername")

	username = request.GET.get('username', '')
	print("username: ", username)

	db = client['tootaloo']
	user_collection = db['users']

	users = user_collection.find({"username": username}, {"_id": 0, "passHash": 0})

	for user in users:
		print("User: ", user)

	resp = HttpResponse(dumps(user, sort_keys=True, indent=4, default=json_util.default))
	resp['Content-Type'] = 'application/json'
	
	return resp

@csrf_exempt
def followUserByUsername(request):
	if request.method == "POST":
		print("POST request received: followUserByUsername")

		followerUsername = request.GET.get('followerUsername', '')
		targetUsername = request.GET.get('targetUsername', '')
		print("followerUsername: ", followerUsername)
		print("targetUsername: ", targetUsername)

		db = client['tootaloo']
		user_collection = db['users']

		target_id = user_collection.find_one({"username": targetUsername}, {"_id": 1})["_id"]

		print("target_id: ", target_id)
		try:
			result = user_collection.update_one({'username': followerUsername}, {'$push':{'following': target_id}})
			resp = HttpResponse(dumps({"response": result.matched_count > 0 }, sort_keys=True, indent=4, default=json_util.default))
			resp['Content-Type'] = 'application/json'
			return resp
		except pymongo.errors.PyMongoError as e:
			resp = HttpResponse(dumps({"response": "failure"}, sort_keys=True, indent=4, default=json_util.default))
			resp['Content-Type'] = 'application/json'


@csrf_exempt
def unfollowUserByUsername(request):
	if request.method == "POST":
		print("POST request received: unfollowUserByUsername")

		followerUsername = request.GET.get('followerUsername', '')
		targetUsername = request.GET.get('targetUsername', '')
		print("followerUsername: ", followerUsername)
		print("targetUsername: ", targetUsername)

		db = client['tootaloo']
		user_collection = db['users']

		target_id = user_collection.find_one({"username": targetUsername}, {"_id": 1})["_id"]

		print("target_id: ", target_id)
		try:
			result = user_collection.update_one({'username': followerUsername}, {'$pull':{'following': target_id}})
			resp = HttpResponse(dumps({"response": result.matched_count > 0 }, sort_keys=True, indent=4, default=json_util.default))
			resp['Content-Type'] = 'application/json'
			return resp
		except pymongo.errors.PyMongoError as e:
			resp = HttpResponse(dumps({"response": "failure"}, sort_keys=True, indent=4, default=json_util.default))
			resp['Content-Type'] = 'application/json'


def index(request):
		#return HttpResponse(review_details)
    return HttpResponse("<h1>Hello and welcome to <u>Tootaloo</u></h1>")



