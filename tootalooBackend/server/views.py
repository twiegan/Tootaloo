from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
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

	print("GET request received: rating")

	ids = request.GET.getlist('ids[]', '')
	print("ids: ", ids)

	db = client['tootaloo']
	ratings_collection = db['ratings']

	ratings = ratings_collection.find({"_id":{"$in": [ObjectId(id) for id in ids]}})

	resp = HttpResponse(dumps(ratings, sort_keys=True, indent=4, default=json_util.default))
	resp['Content-Type'] = 'application/json'
	
	return resp


def restrooms(request):
	'''Endpoint accepts 2 query params (building && floor) used to search db'''

	print("GET request received: restrooms")

	# Connect to db and search restrooms based on query params
	db = client['tootaloo']
	restrooms_collection = db['restrooms']

	building = request.GET.get('building', '')
	floor = request.GET.get('floor', '')\

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


def index(request):
		#return HttpResponse(review_details)
    return HttpResponse("<h1>Hello and welcome to <u>Tootaloo</u></h1>")



