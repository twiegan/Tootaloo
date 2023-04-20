from email.mime.image import MIMEImage
import os
import random
from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_exempt
import certifi
import environ
import pymongo
import json
from bson import ObjectId, json_util
from bson.json_util import dumps
from django.views.decorators.csrf import csrf_exempt
from bson.objectid import ObjectId
from datetime import datetime

# for sending email
import smtplib, ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

import ssl
ssl._create_default_https_context = ssl._create_unverified_context

# Initialize environment variables .env inside of tootalooBackend/
env = environ.Env()
environ.Env.read_env()

# Create your views here.
# def index(request):
#     return HttpResponse('<h1>Hello and welcome to <u>Tootaloo</u></h1>')


# from .models import Restroom
#PyMongo client
client = pymongo.MongoClient(env('MONGODB_CONNECTION_STRING'), tlsCAFile=certifi.where(), serverSelectionTimeoutMS=5000)

@csrf_exempt 
def update_votes(request):
	body_unicode = request.body.decode('utf-8')
	body = json.loads(body_unicode)
	rating_id = ObjectId(body['id'].split()[1].split('}')[0])
	id_query = { '_id':  rating_id}
	new_upvotes = { '$set': { body['type']: int(body['votes']) } }
	print(body['id'], body['votes'])
	
	db = client['tootaloo']
	ratings_collection = db['ratings']
	ratings_collection.update_one(id_query, new_upvotes)

	print(ratings_collection.find_one({'_id': rating_id}))
        
	return HttpResponse()
        

@csrf_exempt
def check_votes(request):
    print("running check votes")
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
    rating_id = ObjectId(body['rating_id'].split()[1].split('}')[0])
    print(rating_id)
    user_id = body['user_id']
    if user_id == 'null':
        return HttpResponse('true')
    user_id = ObjectId(user_id)
    print(user_id)
    db = client['tootaloo']
    ratings_collection = db['ratings']
    rating = ratings_collection.find_one({'_id': rating_id})
    print(rating['voted_users'])
    
    if rating != None and rating['voted_users'] != None and user_id in rating['voted_users']:
        print('true')
        return HttpResponse('true')
    
    if rating != None and rating['voted_users'] != None and user_id not in rating['voted_users']:
        print('updating votes')
        id_query = { '_id':  rating_id}
        new_voted = { '$push': { 'voted_users': user_id } }
        ratings_collection.update_one(id_query, new_voted)

    return HttpResponse('false')


@csrf_exempt
def post_owned(request):
	print('start')
	body_unicode = request.body.decode('utf-8')
	body = json.loads(body_unicode)
	rating_id = ObjectId(body['rating_id'].split()[1].split('}')[0])
	user_id = body['user_id']
	if user_id == 'null':
		return HttpResponse('false')
	user_id = ObjectId(user_id)
	print('what')

	db = client['tootaloo']
	ratings_collection = db['ratings']
	print('here')
	rating = ratings_collection.find_one({'_id': rating_id})

	users_collection = db['users']
	user = users_collection.find_one({'username': rating['by']})
	print(user_id, user['_id'])

	if user and user['_id'] == user_id:
		print('true')
		return HttpResponse('true')
	print('false')
	return HttpResponse('false')


@csrf_exempt
def submit_rating(request):
	body_unicode = request.body.decode('utf-8')
	body = json.loads(body_unicode)
	building = ''
	room = ''
	if body['user_id'] == 'null':
		return HttpResponse('false')
	user_id = ObjectId(user_id)
	if ' ' in body['restroom']:
		building, room = body['restroom'].split()
	
	new_rating = { '_id': ObjectId(), 'building': building, 'room': room, 'overall_rating': float(body['overall_rating']), 'cleanliness': float(body['cleanliness']), 'internet': float(body['internet']), 'vibe': float(body['vibe']), 'review': body['review'], 'upvotes': 0, 'downvotes': 0, 'by': 'FakeUser1', 'createdAt': datetime.today().replace(microsecond=0), 'by_id': user_id }

	db = client['tootaloo']
	restroom_collection = db['restrooms']
	restroom = restroom_collection.find_one({'building': building, 'room': room})
	if restroom:
		print('restroom exits')
		ratings_collection = db['ratings']
		ratings_collection.insert_one(new_rating)

	return HttpResponse()


@csrf_exempt
def edit_rating(request):
	body_unicode = request.body.decode('utf-8')
	body = json.loads(body_unicode)
	rating_id = ObjectId(body['id'].split()[1].split('}')[0])
	building = ''
	room = ''
	if ' ' in body['restroom']:
		building, room = body['restroom'].split()

	db = client['tootaloo']
	restroom_collection = db['restrooms']
	restroom = restroom_collection.find_one({'building': building, 'room': room})
	if restroom:
		print('restroom exits')
		ratings_collection = db['ratings']
		ratings_collection.update_one({'_id': rating_id}, {
			'$set': {
				'building': building, 
				'room': room, 
				'overall_rating': float(body['overall_rating']), 
				'cleanliness': float(body['cleanliness']), 
				'internet': float(body['internet']), 
				'vibe': float(body['vibe']), 
				'review': body['review'],
			}
		})

	return HttpResponse()


def restrooms(request):
	db = client['tootaloo']
	restrooms_collection = db['restrooms']
	restrooms = restrooms_collection.find().sort("rating", -1)
	print(restrooms)
	resp = HttpResponse(dumps(restrooms, sort_keys=True, indent=4, default=json_util.default))
	resp['Content-Type'] = 'application/json'
	
	return resp


@csrf_exempt
def rating_by_id(request):
	body_unicode = request.body.decode('utf-8')
	body = json.loads(body_unicode)
	rating_id = ObjectId(body['rating_id'].split()[1].split('}')[0])
	print(rating_id)

	db = client['tootaloo']
	rating_collection = db['ratings']
	rating = rating_collection.find_one({'_id' : rating_id})
	resp = HttpResponse(dumps(rating, sort_keys=True, indent=4, default=json_util.default))	
	resp['Content-Type'] = 'application/json'

	return resp
	

def ratings(request):
	print('got GET request for ratings')
	
	db = client['tootaloo']

	ratings_collection = db['ratings']

	ratings = ratings_collection.find().sort('upvotes', -1).limit(40)

	resp = HttpResponse(dumps(ratings, sort_keys=True, indent=4, default=json_util.default))
	resp['Content-Type'] = 'application/json'
	
	return resp


def following_ratings(request):
	print('got GET request for ratings')
	
	db = client['tootaloo']

	user_collection = db['users']

	user = user_collection.find({'username': 'FakeUser1'})
	following = user[0]['following']
	print(user[0]['_id'])
	following.append(user[0]['_id'])
	print(following)
	ratings_collection = db['ratings']	

	ratings = ratings_collection.find({'by_id' : {'$in' : following}}).sort('createdAt', -1).limit(40)

	resp = HttpResponse(dumps(ratings, sort_keys=True, indent=4, default=json_util.default))
	resp['Content-Type'] = 'application/json'
	
	return resp


def buildings(request):

	print('got GET request for buildings')

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

	users = user_collection.find({"username": username}, {"passHash": 0})

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


def checkFollowingByUsername(request):
	followerUsername = request.GET.get('followerUsername', '')
	targetUsername = request.GET.get('targetUsername', '')

	db = client['tootaloo']
	user_collection = db['users']

	followerUserFollowing = user_collection.find_one({"username": followerUsername}, {"_id": 0, "following": 1})
	targetUserId = user_collection.find_one({"username": targetUsername}, {"_id": 1})["_id"]

	if targetUserId in followerUserFollowing["following"]:
		resp = HttpResponse(dumps({"response": "Following"}, sort_keys=True, indent=4, default=json_util.default))
		resp['Content-Type'] = 'application/json'
		return resp
	else:
		resp = HttpResponse(dumps({"response": "Not Following"}, sort_keys=True, indent=4, default=json_util.default))
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
  bathroom_preference = user['bathroom_preference']
  
  response = {}

  if user == None:
    response = {'status': "user_dne", 'user_id': userID, 'bathroom_preference': bathroom_preference}
    resp = HttpResponse(dumps(response, sort_keys=True, indent=4, default=json_util.default))
    resp['Content-Type'] = 'application/json'
    return resp

  if user['passHash'] == passHash:
    response = {'status': "good_login", 'user_id': userID, 'bathroom_preference': bathroom_preference}
    resp = HttpResponse(dumps(response, sort_keys=True, indent=4, default=json_util.default))
    resp['Content-Type'] = 'application/json'
    return resp

  response = {'status': "bad_password", 'user_id': userID, 'bathroom_preference': bathroom_preference}
  resp = HttpResponse(dumps(response, sort_keys=True, indent=4, default=json_util.default))
  resp['Content-Type'] = 'application/json'
  return resp

@csrf_exempt
def user_register(request):
  body_unicode = request.body.decode('utf-8')
  body = json.loads(body_unicode)

  username = body['username']
  # passHash = body['passHash']
  # bathroom_preference = body['bathroom_preference']
  email = body['email']

  db = client['tootaloo']
  user_collection = db['users']
  
  pre_existing_user_email = user_collection.find_one({'email': email})
  if pre_existing_user_email != None:
      response = {'status': 'email_taken'}
      resp = HttpResponse(dumps(response, sort_keys=True, indent=4, default=json_util.default))
      resp['Content-Type'] = 'application/json'
      return resp
  
  pre_existing_user = user_collection.find_one({'username': username})
  
  if pre_existing_user == None:
    verification_code = send_verification_email(email)
    print("verification code sent to the user: ", verification_code)
    response = {'status': 'register_success', 'verification_code': verification_code}
  else:
    response = {'status': 'username_taken'}
  
  resp = HttpResponse(dumps(response, sort_keys=True, indent=4, default=json_util.default))
  resp['Content-Type'] = 'application/json'
  return resp

@csrf_exempt
def insert_user(request):
  body_unicode = request.body.decode('utf-8')
  body = json.loads(body_unicode)

  username = body['username']
  passHash = body['passHash']
  bathroom_preference = body['bathroom_preference']
  email = body['email']

  db = client['tootaloo']
  user_collection = db['users']
  new_user = {'_id': ObjectId(), 'username': username, 'posts': [], 'following': [], 'passHash': passHash, 'bathroom_preference': bathroom_preference, 'email': email}
  _id = user_collection.insert_one(new_user)
  print("inserted user with id: ", _id.inserted_id)
  
  return HttpResponse("user_insert_success")

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
      '_id': pre_existing_user['_id']
    },{
      '$set': {
        'bathroom_preference': body['bathroom_preference']
      }
    })
    return HttpResponse("save_success")
  else:
    return HttpResponse("save_fail")


def send_verification_email(receiver_email):
	sender_email = env('SENDER_EMAIL')
	email_password = env('EMAIL_PASSWORD')
 
	message = MIMEMultipart("alternative")
	message["Subject"] = "Verification Code for Tootaloo"
	message["From"] = sender_email
	message["To"] = receiver_email

	# Random 4 digit verification code
	code = random.randint(1000, 9999)

	# Create the plain-text and HTML version of your message
	html = f"""\
	<!DOCTYPE html>
	<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:o="urn:schemas-microsoft-com:office:office">
		<head>
				<meta charset="UTF-8">
				<meta name="viewport" content="width=device-width,initial-scale=1">
				<meta name="x-apple-disable-message-reformatting">
				<title></title>
				<!--[if mso]>
				<noscript>
					<xml>
							<o:OfficeDocumentSettings>
								<o:PixelsPerInch>96</o:PixelsPerInch>
							</o:OfficeDocumentSettings>
					</xml>
				</noscript>
				<![endif]-->
				<style>
					table,
					td,
					div,
					h1,
					p {{
					font-family: Arial, sans-serif;
					}}
				</style>
		</head>
		<body style="margin:0;padding:0;">
				<table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;background:#ffffff;">
					<tr>
							<td align="center" style="padding:0;">
								<table role="presentation" style="width:602px;border-collapse:collapse;border:1px solid #cccccc;border-spacing:0;text-align:left;">
										<tr>
											<td align="center" style="padding:10px 0 10px 0;background:#dff1ff;">
													<img src="data:image/png;base64,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" alt="" width="150" style="height:auto;display:block;" />
													<img alt="" width="150" style="height:auto;display:block;" src="cid:tootalooLogo"/>
           						</td>
										</tr>
										<tr>
											<td style="padding:30px 3px 0px 30px;">
													<table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;">
														<tr>
																<td style="padding:0 0 3px 0;color:#153643;">
																	<h1 style="font-size:24px;margin:0 0 20px 0;font-family:Arial,sans-serif;">Verification Code: 
																			<a style="color:#203354;text-decoration:underline;">{code}</a>
																	</h1>
																</td>
														</tr>
													</table>
											</td>
										</tr>
								</table>
							</td>
					</tr>
				</table>
		</body>
	</html>
	"""
 
	# Add HTML/plain-text parts to MIMEMultipart message
	message.attach(MIMEText(html, "html"))
 
	# Attach Tootaloo logo
	logoPath = os.path.join(os.path.dirname(os.path.dirname(__file__)),'server/assets/tootalooLogo.png')
	fp = open(logoPath, 'rb')
	messageImage = MIMEImage(fp.read())
	fp.close()

	messageImage.add_header('Content-ID', 'tootalooLogo')
	message.attach(messageImage)

	# Create secure connection with server and send email
	context = ssl.create_default_context()
	with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
			server.login(sender_email, email_password)
			server.sendmail(
					sender_email, receiver_email, message.as_string()
			)
   
	return code

def index(request):
		#return HttpResponse(review_details)
    return HttpResponse('<h1>Hello and welcome to <u>Tootaloo</u></h1>')



