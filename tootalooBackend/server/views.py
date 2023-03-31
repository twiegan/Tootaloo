from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
import certifi
import environ
import pymongo
import json
from bson import ObjectId, json_util
from bson.json_util import dumps
from django.views.decorators.csrf import csrf_exempt
from datetime import datetime

# Initialize environment variables .env inside of tootalooBackend/
env = environ.Env()
environ.Env.read_env()

# Create your views here.
# def index(request):
#     return HttpResponse("<h1>Hello and welcome to <u>Tootaloo</u></h1>")


#PyMongo client
client = pymongo.MongoClient(env('MONGODB_CONNECTION_STRING'), tlsCAFile=certifi.where(), serverSelectionTimeoutMS=5000)

@csrf_exempt 
def submit_rating(request):
	body_unicode = request.body.decode('utf-8')
	body = json.loads(body_unicode)
	building = ''
	room = ''
	if ' ' in body['restroom']:
		building, room = body['restroom'].split()
	
	new_rating = { '_id': ObjectId(), 'building': building, 'room': room, 'overall_rating': float(body['overall_rating']), 'cleanliness': float(body['cleanliness']), 'internet': float(body['internet']), 'vibe': float(body['vibe']), 'review': body['review'], 'upvotes': 0, 'downvotes': 0, 'by': 'FakeUser1', 'createdAt': datetime.today().replace(microsecond=0), 'by_id': ObjectId('507f191e810c19729de860ea')}


	db = client['tootaloo']
	restroom_collection = db['restrooms']
	restroom = restroom_collection.find_one({'building': building, 'room': room})
	if restroom:
		print('restroom exits')
		ratings_collection = db['ratings']
		ratings_collection.insert_one(new_rating)

	return HttpResponse()


def restrooms(request):
	db = client['tootaloo']
	restrooms_collection = db['restrooms']
	restrooms = restrooms_collection.find().sort("rating", -1)
	print(restrooms)
	resp = HttpResponse(dumps(restrooms, sort_keys=True, indent=4, default=json_util.default))
	resp['Content-Type'] = 'application/json'
	
	return resp


def ratings(request):
	print("got GET request for ratings")
	
	db = client['tootaloo']

	ratings_collection = db['ratings']	

	ratings = ratings_collection.find().sort("upvotes", -1).limit(40)

	resp = HttpResponse(dumps(ratings, sort_keys=True, indent=4, default=json_util.default))
	resp['Content-Type'] = 'application/json'
	
	return resp


def following_ratings(request):
	print("got GET request for ratings")
	
	db = client['tootaloo']

	user_collection = db['users']

	user = user_collection.find({'username': 'FakeUser1'})
	following = user[0]['following']
	print(user[0]['_id'])
	following.append(user[0]['_id'])
	print(following)
	ratings_collection = db['ratings']	

	ratings = ratings_collection.find({'by_id' : {'$in' : following}}).sort("createdAt", -1).limit(40)

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

@csrf_exempt
def login(request):
  body_unicode = request.body.decode('utf-8')
  body = json.loads(body_unicode)
  username = body['username']
  passHash = body['passHash']

  db = client['tootaloo']
  user_collection = db['users']

  user = user_collection.find_one({'username': username})
  userID = str(user.get('_id'))


  if user == None:
    response = "user_dne " + userID
    return HttpResponse(response)

  if user['passHash'] == passHash:
    response = "good_login " + userID
    return HttpResponse(response)

  response = "bad_password " + userID
  return HttpResponse(response)

@csrf_exempt
def user_register(request):
  body_unicode = request.body.decode('utf-8')
  body = json.loads(body_unicode)

  username = body['username']
  passHash = body['passHash']
  bathroom_preference = body['bathroom_preference']
  print("BATHROOM RESPONSE: " + bathroom_preference)

  db = client['tootaloo']
  user_collection = db['users']
  pre_existing_user = user_collection.find_one({'username': username})

  if pre_existing_user == None:
    new_user = {'_id': ObjectId(), 'username': username, 'posts': [], 'following': [], 'passHash': passHash, 'bathroom_preference': bathroom_preference}
    user_collection.insert_one(new_user)
    return HttpResponse("register_success")
  else:
    return HttpResponse("username_taken")

@csrf_exempt
def save_user_settings(request):
  body_unicode = request.body.decode('utf-8')
  body = json.loads(body_unicode)

  username = body['username']

  db = client['tootaloo']
  user_collection = db['users']
  pre_existing_user = user_collection.find_one({'username': username})

  if pre_existing_user != None:
    user_collection.update_one({
      'username': pre_existing_user['username']
    },{
      '$set': {
        'bathroom_preference': body['bathroom_preference']
      }
    })
    return HttpResponse("save_success")
  else:
    return HttpResponse("save_fail")



def index(request):
		#return HttpResponse(review_details)
    return HttpResponse("<h1>Hello and welcome to <u>Tootaloo</u></h1>")



