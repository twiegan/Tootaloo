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

def summary_ratings_building(request):  
  buildingId = request.GET.get('building')
  
  db = client['tootaloo']
  
  ratings_collection = db['ratings']	
  
  numRatings = ratings_collection.count_documents({'building': buildingId})
  if numRatings == 0:
    resp = HttpResponse("No ratings for this building.")
    resp['Content-Type'] = 'text/plain'
    return resp
  
  ratings = ratings_collection.find({'building': buildingId}, {'overall_rating': 1, 'cleanliness': 1, 'internet': 1, 'vibe': 1, '_id': 0})  
  
  overallRatingAvg = 0
  cleanlinessAvg = 0
  internetAvg = 0
  vibeAvg = 0
  
  for rating in ratings:
    overallRatingAvg += rating['overall_rating']
    cleanlinessAvg += rating['cleanliness']
    internetAvg += rating['internet']
    vibeAvg += rating['vibe']
    
  overallRatingAvg /= numRatings
  cleanlinessAvg /= numRatings
  internetAvg /= numRatings
  vibeAvg /= numRatings
  
  ratingResult = "Average ratings: Overall: {0:.2f}\nCleanliness: {1:.2f}, Internet: {2:.2f}, Vibe: {3:.2f}".format(overallRatingAvg, cleanlinessAvg, internetAvg, vibeAvg)
  
  resp = HttpResponse(ratingResult)
  resp['Content-Type'] = 'application/json'
  
  return resp

def index(request):
		#return HttpResponse(review_details)
    return HttpResponse("<h1>Hello and welcome to <u>Tootaloo</u></h1>")



