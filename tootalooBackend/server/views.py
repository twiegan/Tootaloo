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
	
	new_rating = { '_id': ObjectId(), 'building': building, 'room': room, 'overall_rating': float(body['overall_rating']), 'cleanliness': float(body['cleanliness']), 'internet': float(body['internet']), 'vibe': float(body['vibe']), 'review': body['review'], 'upvotes': 0, 'downvotes': 0, 'by': 'FakeUser1', 'createdAt': datetime.today().replace(microsecond=0), 'by_id': user_id, 'voted_users': [], 'reported_users': [], 'reports': 0 }

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
 
	message = MIMEMultipart("related")
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

@csrf_exempt 
def updateRatingReports(request):
	print("POST request: updateRatingReports")
	body_unicode = request.body.decode('utf-8')
	body = json.loads(body_unicode)
	type = body['type']
	rating_id = ObjectId(body['id'].split()[1].split('}')[0])
	query = {'_id':  rating_id}
	update_expression = {'$inc': {"reports" : 1}}
	
	db = client['tootaloo']
	collection = db[type]
	collection.update_one(query, update_expression)
        
	return HttpResponse()
        

@csrf_exempt
def checkRatingReported(request):
	print("POST request: checkRatingReported")
	body_unicode = request.body.decode('utf-8')
	body = json.loads(body_unicode)
	rating_id = ObjectId(body['rating_id'].split()[1].split('}')[0])
	user_id = body['user_id']
	if user_id == 'null':
		return HttpResponse('true')
	
	user_id = ObjectId(user_id)
	db = client['tootaloo']

	ratings_collection = db['ratings']
	rating = ratings_collection.find_one({'_id': rating_id})

	if rating != None and rating['reported_users'] != None and user_id in rating['reported_users']:
		return HttpResponse('true')

	if rating != None and rating['reported_users'] != None and user_id not in rating['reported_users']:
		id_query = { '_id':  rating_id}
		new_voted = { '$push': { 'reported_users': user_id } }
		ratings_collection.update_one(id_query, new_voted)

	return HttpResponse('false')

@csrf_exempt 
def updateUserReports(request):
	print("POST request: updateUserReports")
	body_unicode = request.body.decode('utf-8')
	body = json.loads(body_unicode)
	reported_username = body['reported_username']
	print('reported_username: ', reported_username)
	
	db = client['tootaloo']
	users_collection = db['users']
	reported_user = users_collection.find_one({'username': reported_username})
	reported_id = reported_user['_id']
	print('reported_user: ', reported_user)
	print('reported_id: ', reported_id)

	query = {'_id':  reported_id}
	update_expression = {'$inc': {"reports" : 1}}
	print('query & update_expression: ', query, update_expression)
	users_collection.update_one(query, update_expression)
        
	return HttpResponse()
        

@csrf_exempt
def checkUserReported(request):
	print("POST request: checkUserReported")
	body_unicode = request.body.decode('utf-8')
	body = json.loads(body_unicode)
	reported_username = body['reported_username']
	print("reported_username: ", reported_username)
	user_id = body['user_id']
	print("user_id: ", user_id)
	if user_id == 'null':
		return HttpResponse('true')
	
	user_id = ObjectId(user_id)
	db = client['tootaloo']

	users_collection = db['users']
	reported_user = users_collection.find_one({'username': reported_username})
	reported_id = reported_user['_id']
	print('reported_user: ', reported_user)
	print('reported_id: ', reported_id)

	if reported_user != None and reported_user['reported_users'] != None and user_id in reported_user['reported_users']:
		return HttpResponse('true')

	if reported_user != None and reported_user['reported_users'] != None and user_id not in reported_user['reported_users']:
		id_query = { '_id': reported_id }
		new_voted = { '$push': { 'reported_users': user_id } }
		users_collection.update_one(id_query, new_voted)

	return HttpResponse('false')

