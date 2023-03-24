from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
import certifi
import environ
import pymongo
import json
from bson import json_util
from bson.json_util import dumps

# Initialize environment variables .env inside of tootalooBackend/
env = environ.Env()
environ.Env.read_env()

# Create your views here.
# def index(request):
#     return HttpResponse("<h1>Hello and welcome to <u>Tootaloo</u></h1>")


#PyMongo client
client = pymongo.MongoClient(env('MONGODB_CONNECTION_STRING'), tlsCAFile=certifi.where(), serverSelectionTimeoutMS=5000)


def restrooms(request):
	db = client['tootaloo']
	restrooms_collection = db['restrooms']
	restrooms = restrooms_collection.find().sort("rating", -1).limit(20)
	print(restrooms)
	resp = HttpResponse(dumps(restrooms, sort_keys=True, indent=4, default=json_util.default))
	resp['Content-Type'] = 'application/json'
	
	return resp


def ratings(request):
	print("got GET request for ratings")
	
	db = client['tootaloo']

	ratings_collection = db['ratings']	

	ratings = ratings_collection.find()
	resp = HttpResponse(dumps(ratings, sort_keys=True, indent=4, default=json_util.default))
	resp['Content-Type'] = 'application/json'
	
	return resp


def following_ratings(request):
	print("got GET request for ratings")
	
	db = client['tootaloo']

	user_collection = db['users']

	user = user_collection.find({'username': 'FakeUser1'})
	following = user[0]['following']
	ratings_collection = db['ratings']	

	ratings = ratings_collection.find({'by' : {'$in' : following}}).sort("upvotes", -1).limit(20)

	resp = HttpResponse(dumps(ratings, sort_keys=True, indent=4, default=json_util.default))
	resp['Content-Type'] = 'application/json'
	
	return resp


def buildings(request):

	print("got GET request for buildings")

	db = client['tootaloo']
	buildings_collection = db['buildings']

	buildings = buildings_collection.find()

	resp = HttpResponse(dumps(buildings, sort_keys=True, indent=4, default=json_util.default))
	resp['Content-Type'] = 'application/json'
	
	return resp

def index(request):
		#return HttpResponse(review_details)
    return HttpResponse("<h1>Hello and welcome to <u>Tootaloo</u></h1>")



