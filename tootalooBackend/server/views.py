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
import smtplib
import ssl
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
# PyMongo client
client = pymongo.MongoClient(env('MONGODB_CONNECTION_STRING'),
                             tlsCAFile=certifi.where(), serverSelectionTimeoutMS=5000)


@csrf_exempt
def update_votes(request):
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
    if '{' in body['id']:
        rating_id = ObjectId(body['id'].split()[1].split('}')[0])
    else:
        rating_id = ObjectId(body['id'])
    id_query = {'_id': rating_id}
    new_upvotes = {'$set': {body['type']: int(body['votes'])}}

    db = client['tootaloo']
    ratings_collection = db['ratings']
    ratings_collection.update_one(id_query, new_upvotes)

    return HttpResponse()


@csrf_exempt
def check_votes(request):
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
    if '{' in body['rating_id']:
        rating_id = ObjectId(body['rating_id'].split()[1].split('}')[0])
    else:
        rating_id = ObjectId(body['rating_id'])
    user_id = body['user_id']
    if user_id == 'null':
        return HttpResponse('true')
    user_id = ObjectId(user_id)
    db = client['tootaloo']
    ratings_collection = db['ratings']
    rating = ratings_collection.find_one({'_id': rating_id})

    if rating != None and rating['voted_users'] != None and user_id in rating['voted_users']:
        return HttpResponse('true')

    if rating != None and rating['voted_users'] != None and user_id not in rating['voted_users']:
        id_query = {'_id': rating_id}
        new_voted = {'$push': {'voted_users': user_id}}
        ratings_collection.update_one(id_query, new_voted)

    return HttpResponse('false')


@csrf_exempt
def post_owned(request):
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
    print('owned ids: ')
    print(body['rating_id'])
    if '{' in body['rating_id']:
        rating_id = ObjectId(body['rating_id'].split()[1].split('}')[0])
    else:
        rating_id = ObjectId(body['rating_id'])

    user_id = body['user_id']
    if user_id == 'null':
        return HttpResponse('false')
    user_id = ObjectId(user_id)

    db = client['tootaloo']
    ratings_collection = db['ratings']
    rating = ratings_collection.find_one({'_id': rating_id})

    users_collection = db['users']
    user = users_collection.find_one({'username': rating['by']})

    if user and user['_id'] == user_id:
        return HttpResponse('true')
    return HttpResponse('false')


@csrf_exempt
def submit_rating(request):
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
    building = ''
    room = ''
    if body['user_id'] == 'null':
        return HttpResponse('false')
    user_id = ObjectId(body['user_id'])
    if ' ' in body['restroom']:
        building, room = body['restroom'].split()
    new_id = ObjectId()

    db = client['tootaloo']
    restroom_collection = db['restrooms']
    restroom = restroom_collection.find_one(
        {'building': building, 'room': room})
    user_collection = db['users']
    user = user_collection.find_one({'_id': user_id})
    print(user)
    new_rating = {'_id': new_id, 'building': building, 'room': room, 'overall_rating': float(body['overall_rating']),
                  'cleanliness': float(body['cleanliness']), 'internet': float(body['internet']),
                  'vibe': float(body['vibe']), 'privacy': float(body['privacy']), 'review': body['review'],
                  'upvotes': 0, 'downvotes': 0, 'by': user['username'],
                  'createdAt': datetime.today().replace(microsecond=0), 'by_id': user_id, 'voted_users': [],
                  'reported_users': [], 'reports': 0}

    if restroom:
        ratings_collection = db['ratings']
        ratings_collection.insert_one(new_rating)
        new_cleanliness = ((restroom['cleanliness'] * len(restroom['ratings'])) + float(body['cleanliness'])) / (
            len(restroom['ratings']) + 1)
        new_internet = ((restroom['internet'] * len(restroom['ratings'])) + float(body['internet'])) / (
            len(restroom['ratings']) + 1)
        new_vibe = ((restroom['vibe'] * len(restroom['ratings'])) + float(body['vibe'])) / (
            len(restroom['ratings']) + 1)
        new_privacy = ((restroom['privacy'] * len(restroom['ratings'])) + float(body['privacy'])) / (
            len(restroom['ratings']) + 1)
        new_overall = (new_cleanliness + new_internet +
                       new_vibe + new_privacy) / 4
        restroom_collection.update_one({'_id': restroom['_id']}, {
            '$set': {
                'cleanliness': new_cleanliness,
                'internet': new_internet,
                'vibe': new_vibe,
                'privacy': new_privacy,
                'rating': new_overall,
            }
        })
        restroom_collection.update_one({'_id': restroom['_id']}, {
            '$push': {
                'ratings': new_id,
            }
        })
        user_collection.update_one({'_id': user_id}, {
            '$push': {
                'posts': new_id,
            }
        })

    return HttpResponse()


@csrf_exempt
def edit_rating(request):
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
    if '{' in body['id']:
        rating_id = ObjectId(body['id'].split()[1].split('}')[0])
    else:
        rating_id = ObjectId(body['id'])
    building = ''
    room = ''
    if ' ' in body['restroom']:
        building, room = body['restroom'].split()

    db = client['tootaloo']
    restroom_collection = db['restrooms']
    restroom = restroom_collection.find_one(
        {'building': building, 'room': room})
    if restroom:
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
        
        old_rating = ratings_collection.find_one({'_id': rating_id})

        # remove old rating
        # new_cleanliess -= restroom['cleanliness']
        # new_internet -= restroom['internet']
        # new_vibe -= restroom['vibe']
        # new_privacy -= restroom['privacy']

        print("========= inside of edit rating")

        new_cleanliness = ((restroom['cleanliness'] * len(restroom['ratings']) - old_rating['cleanliness']) + float(body['cleanliness'])) / (
            len(restroom['ratings']))
        new_internet = ((restroom['internet'] * len(restroom['ratings']) - old_rating['internet']) + float(body['internet'])) / (
            len(restroom['ratings']))
        new_vibe = ((restroom['vibe'] * len(restroom['ratings']) - old_rating['vibe']) + float(body['vibe'])) / (
            len(restroom['ratings']))
        new_privacy = ((restroom['privacy'] * len(restroom['ratings']) - old_rating['privacy']) + float(body['privacy'])) / (
            len(restroom['ratings']))
        new_overall = (new_cleanliness + new_internet +
                       new_vibe + new_privacy) / 4
        
        print("========= inside of edit rating")
        print(new_cleanliness, new_internet, new_vibe, new_privacy)

        restroom_collection.update_one({'_id': restroom['_id']}, {
            '$set': {
                'cleanliness': new_cleanliness,
                'internet': new_internet,
                'vibe': new_vibe,
                'privacy': new_privacy,
                'rating': new_overall,
            }
        })

    return HttpResponse()


@csrf_exempt
def delete_post(request):
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
    if '{' in body['id']:
        rating_id = ObjectId(body['id'].split()[1].split('}')[0])
    else:
        rating_id = ObjectId(body['id'])
    user_id = body['user_id']

    if user_id == 'null':
        return HttpResponse('true')

    if '{' in body['user_id']:
        user_id = ObjectId(body['user_id'].split()[1].split('}')[0])
    else:
        rating_id = ObjectId(body['user_id'])

    db = client['tootaloo']
    rating_collection = db['ratings']
    user_collection = db['users']
    rating = rating_collection.find_one({'_id': rating_id})
    rating_collection.delete_one({'_id': rating_id})
    user_collection.update_one(
        {'_id': user_id},
        {'$pull': {'posts': rating_id}}
    )
    restroom_collection = db['restrooms']
    restroom = restroom_collection.find_one(
        {'building': rating['building'], 'room': rating['room']})

    if len(restroom['ratings']) - 1 == 0:
        # handle division by zero
        new_cleanliness = new_internet = new_vibe = new_privacy = 0
    else:
        new_cleanliness = ((restroom['cleanliness'] * len(restroom['ratings'])) - float(rating['cleanliness'])) / (
            len(restroom['ratings']) - 1)
        new_internet = ((restroom['internet'] * len(restroom['ratings'])) - float(rating['internet'])) / (
            len(restroom['ratings']) - 1)
        new_vibe = ((restroom['vibe'] * len(restroom['ratings'])) -
                    float(rating['vibe'])) / (len(restroom['ratings']) - 1)
        new_privacy = ((restroom['privacy'] * len(restroom['ratings'])) - float(rating['privacy'])) / (
            len(restroom['ratings']) - 1)
    new_overall = (new_cleanliness + new_internet + new_vibe + new_privacy) / 4

    restroom_collection.update_one({'_id': restroom['_id']}, {
        '$set': {
            'cleanliness': new_cleanliness,
            'internet': new_internet,
            'vibe': new_vibe,
            'privacy': new_privacy,
            'rating': new_overall,
        }
    })
    restroom_collection.update_one({'_id': restroom['_id']}, {
        '$pull': {
            'ratings': rating['_id'],
        }
    })
    user_collection.update_one({'_id': user_id}, {
        '$pull': {
            'posts': rating['_id'],
        }
    })

    return HttpResponse()


def restrooms(request):
    db = client['tootaloo']
    restrooms_collection = db['restrooms']
    restrooms = restrooms_collection.find().sort("rating", -1)
    print(restrooms)
    resp = HttpResponse(dumps(restrooms, sort_keys=True,
                              indent=4, default=json_util.default))
    resp['Content-Type'] = 'application/json'

    return resp


def users(request):
    db = client['tootaloo']
    users_collection = db['users']
    users = users_collection.find().sort("username", -1)
    print(users)
    resp = HttpResponse(dumps(users, sort_keys=True,
                              indent=4, default=json_util.default))
    resp['Content-Type'] = 'application/json'

    return resp


@csrf_exempt
def rating_by_id(request):
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
    if '{' in body['rating_id']:
        rating_id = ObjectId(body['rating_id'].split()[1].split('}')[0])
    else:
        rating_id = ObjectId(body['rating_id'])
    print(rating_id)

    db = client['tootaloo']
    rating_collection = db['ratings']
    rating = rating_collection.find_one({'_id': rating_id})
    resp = HttpResponse(dumps(rating, sort_keys=True,
                              indent=4, default=json_util.default))
    resp['Content-Type'] = 'application/json'

    return resp


def ratings(request):
    print('got GET request for ratings')

    db = client['tootaloo']

    ratings_collection = db['ratings']

    ratings = ratings_collection.find().sort('upvotes', -1).limit(40)

    resp = HttpResponse(dumps(ratings, sort_keys=True,
                              indent=4, default=json_util.default))
    resp['Content-Type'] = 'application/json'

    return resp


@csrf_exempt
def following_ratings(request):
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)

    user_id = body['user_id']
    if user_id == 'null':
        return HttpResponse('No user_id')
    user_id = ObjectId(user_id)

    db = client['tootaloo']
    user_collection = db['users']

    user = user_collection.find_one({'_id': user_id})
    following = user['following']
    following.append(user['_id'])
    ratings_collection = db['ratings']

    ratings = ratings_collection.find(
        {'by_id': {'$in': following}}).sort('createdAt', 1).limit(40)

    resp = HttpResponse(dumps(ratings, sort_keys=True,
                              indent=4, default=json_util.default))
    resp['Content-Type'] = 'application/json'

    return resp


def buildings(request):
    print('got GET request for buildings')

    db = client['tootaloo']
    buildings_collection = db['buildings']

    buildings = buildings_collection.find()

    resp = HttpResponse(dumps(buildings, sort_keys=True,
                              indent=4, default=json_util.default))
    resp['Content-Type'] = 'application/json'

    return resp


def building_by_id(request):
    db = client['tootaloo']
    buildings_collection = db['buildings']

    buildingId = request.GET.get('building')
    building = buildings_collection.find_one({"_id": buildingId})

    resp = HttpResponse(dumps(building, sort_keys=True,
                              indent=4, default=json_util.default))
    resp['Content-Type'] = 'application/json'

    return resp


@csrf_exempt
def ratingsByIds(request):

    print("GET request received: ratings")
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
    ids = body['ids[]']
    print("ids: ", ids)

    db = client['tootaloo']
    ratings_collection = db['ratings']

    ratings_data = ratings_collection.find({"_id": {"$in": [ObjectId(
        id['$oid']) if '$oid' in id else ObjectId(id) for id in ids]}})

    ratings = []
    for rating in ratings_data:
        ratings.append(rating)

    resp = HttpResponse(dumps(ratings, sort_keys=True,
                              indent=4, default=json_util.default))
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
        restrooms = restrooms_collection.find(
            {'building': building, 'floor': int(floor)})
    else:
        return None

    # Return response
    resp = HttpResponse(dumps(restrooms, sort_keys=True,
                              indent=4, default=json_util.default))
    resp['Content-Type'] = 'application/json'

    return resp


@csrf_exempt
def userByUsername(request):
    print("GET request received: userByUsername")
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
    username = body['username']
    print("username: ", username)

    db = client['tootaloo']
    user_collection = db['users']

    user = user_collection.find_one({"username": username})

    resp = HttpResponse(
        dumps(user, sort_keys=True, indent=4, default=json_util.default))
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

        target_id = user_collection.find_one(
            {"username": targetUsername}, {"_id": 1})["_id"]

        print("target_id: ", target_id)
        try:
            result = user_collection.update_one({'username': followerUsername}, {
                                                '$push': {'following': target_id}})
            user_collection.update_one({'username': targetUsername}, {
                                       '$inc': {'followers': 1}})

            resp = HttpResponse(
                dumps({"response": result.matched_count > 0}, sort_keys=True, indent=4, default=json_util.default))
            resp['Content-Type'] = 'application/json'
            return resp
        except pymongo.errors.PyMongoError as e:
            resp = HttpResponse(dumps(
                {"response": "failure"}, sort_keys=True, indent=4, default=json_util.default))
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

        target_id = user_collection.find_one(
            {"username": targetUsername}, {"_id": 1})["_id"]

        print("target_id: ", target_id)
        try:
            result = user_collection.update_one({'username': followerUsername}, {
                '$pull': {'following': target_id}})
            user_collection.update_one({'username': targetUsername}, {
                                       '$inc': {'followers': -1}})
            resp = HttpResponse(
                dumps({"response": result.matched_count > 0}, sort_keys=True, indent=4, default=json_util.default))
            resp['Content-Type'] = 'application/json'
            return resp
        except pymongo.errors.PyMongoError as e:
            resp = HttpResponse(dumps(
                {"response": "failure"}, sort_keys=True, indent=4, default=json_util.default))
            resp['Content-Type'] = 'application/json'


def checkFollowingByUsername(request):
    followerUsername = request.GET.get('followerUsername', '')
    targetUsername = request.GET.get('targetUsername', '')

    db = client['tootaloo']
    user_collection = db['users']

    followerUserFollowing = user_collection.find_one(
        {"username": followerUsername}, {"_id": 0, "following": 1})
    targetUserId = user_collection.find_one(
        {"username": targetUsername}, {"_id": 1})["_id"]

    if targetUserId in followerUserFollowing["following"]:
        resp = HttpResponse(dumps(
            {"response": "Following"}, sort_keys=True, indent=4, default=json_util.default))
        resp['Content-Type'] = 'application/json'
        return resp
    else:
        resp = HttpResponse(dumps(
            {"response": "Not Following"}, sort_keys=True, indent=4, default=json_util.default))
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

    ratings = ratings_collection.find({'building': buildingId},
                                      {'overall_rating': 1, 'cleanliness': 1, 'internet': 1, 'vibe': 1, '_id': 0})

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

    ratingResult = "Average ratings: Overall: {0:.2f}\nCleanliness: {1:.2f}, Internet: {2:.2f}, Vibe: {3:.2f}".format(
        overallRatingAvg, cleanlinessAvg, internetAvg, vibeAvg)

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
    if user == None:
        # user DNE
        response = {'status': "user_dne", 'user_id': '',
                    'bathroom_preference': ''}
        resp = HttpResponse(dumps(response, sort_keys=True,
                                  indent=4, default=json_util.default))
        resp['Content-Type'] = 'application/json'
        return resp

    userID = str(user.get('_id'))
    bathroom_preference = user['bathroom_preference']

    response = {}

    if user['passHash'] == passHash:
        response = {'status': "good_login", 'user_id': userID,
                    'bathroom_preference': bathroom_preference}
        resp = HttpResponse(dumps(response, sort_keys=True,
                                  indent=4, default=json_util.default))
        resp['Content-Type'] = 'application/json'
        return resp

    response = {'status': "bad_password", 'user_id': userID,
                'bathroom_preference': bathroom_preference}
    resp = HttpResponse(dumps(response, sort_keys=True,
                              indent=4, default=json_util.default))
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
        resp = HttpResponse(dumps(response, sort_keys=True,
                                  indent=4, default=json_util.default))
        resp['Content-Type'] = 'application/json'
        return resp

    pre_existing_user = user_collection.find_one({'username': username})

    if pre_existing_user == None:
        verification_code = send_verification_email(email)
        print("verification code sent to the user: ", verification_code)
        response = {'status': 'register_success',
                    'verification_code': verification_code}
    else:
        response = {'status': 'username_taken'}

    resp = HttpResponse(dumps(response, sort_keys=True,
                              indent=4, default=json_util.default))
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
    new_user = {'_id': ObjectId(), 'username': username, 'posts': [], 'following': [], 'passHash': passHash,
                'bathroom_preference': bathroom_preference, 'email': email, "favorite_restrooms": [],
                'reported_users': [], 'reports': 0, 'followers': 0}
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
        }, {
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
    logoPath = os.path.join(os.path.dirname(
        os.path.dirname(__file__)), 'server/assets/tootalooLogo.png')
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
    # return HttpResponse(review_details)
    return HttpResponse('<h1>Hello and welcome to <u>Tootaloo</u></h1>')


@csrf_exempt
def updateRatingReports(request):
    print("POST request: updateRatingReports")
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
    # type = body['type']
    rating_id = ObjectId(body['id'].split()[1].split('}')[0])

    db = client['tootaloo']
    ratings_collection = db['ratings']
    rating = ratings_collection.find_one({'_id': rating_id})

    # increment reports count by one
    query = {'_id': rating_id}
    update_expression = {'$inc': {"reports": 1}}
    ratings_collection.update_one(query, update_expression)

    # get the id of the user who reported the rating
    id_reported_by = body['id_reported_by']
    id_reported_by = ObjectId(id_reported_by)

    if rating != None and rating['reported_users'] != None and id_reported_by not in rating['reported_users']:
        # push the id the of the user who reported the rating to the reported_users list
        id_query = {'_id': rating_id}
        new_voted = {'$push': {'reported_users': id_reported_by}}
        ratings_collection.update_one(id_query, new_voted)

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

    # if rating != None and rating['reported_users'] != None and user_id not in rating['reported_users']:
    #     id_query = {'_id': rating_id}
    #     new_voted = {'$push': {'reported_users': user_id}}
    #     ratings_collection.update_one(id_query, new_voted)

    return HttpResponse('false')


@csrf_exempt
def updateUserReports(request):
    print("POST request: updateUserReports")
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
    reported_username = body['reported_username']
    print('reported_username: ', reported_username)

    # find the id of the user that got reported from the database
    db = client['tootaloo']
    users_collection = db['users']
    reported_user = users_collection.find_one({'username': reported_username})
    reported_id = reported_user['_id']
    print('reported_user: ', reported_user)
    print('reported_id: ', reported_id)

    # increment reports count by one
    query = {'_id': reported_id}
    update_expression = {'$inc': {"reports": 1}}
    print('query & update_expression: ', query, update_expression)
    users_collection.update_one(query, update_expression)

    # get the id of the user who reported the rating
    id_reported_by = body['id_reported_by']
    id_reported_by = ObjectId(id_reported_by)

    if reported_user != None and reported_user['reported_users'] != None and id_reported_by not in reported_user[
            'reported_users']:
        # push the id the of the user who reported the rating to the reported_users list
        id_query = {'_id': reported_id}
        new_voted = {'$push': {'reported_users': id_reported_by}}
        users_collection.update_one(id_query, new_voted)

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

    return HttpResponse('false')


@csrf_exempt
def restroom_id_by_name(request):
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
    building = body['building']
    room = body['room']

    db = client['tootaloo']
    restrooms_collection = db['restrooms']
    print(building, room)
    restroom = restrooms_collection.find_one(
        {'building': building, 'room': room})

    response = {'status': "success", 'id': restroom['_id']}
    resp = HttpResponse(dumps(response, sort_keys=True,
                              indent=4, default=json_util.default))
    resp['Content-Type'] = 'application/json'
    return resp


@csrf_exempt
def restroomById(request):
    restroom_id = ObjectId(request.GET.get('restroom_id', ''))

    db = client['tootaloo']
    restrooms_collection = db['restrooms']
    restroom = restrooms_collection.find_one({'_id': restroom_id})

    response = {'status': "success", 'restroom': restroom}
    resp = HttpResponse(dumps(response, sort_keys=True,
                              indent=4, default=json_util.default))
    resp['Content-Type'] = 'application/json'
    return resp


@csrf_exempt
def removeUser(request):
    username = request.GET.get('username')

    db = client['tootaloo']
    user_collection = db['users']
    pre_existing_user = user_collection.find_one({'username': username})

    if pre_existing_user is not None:
        user_collection.delete_one({'_id': pre_existing_user['_id']})
        user_collection = db['ratings']
        for post in pre_existing_user['posts']:
            user_collection.delete_one({'_id': post['_id']})
        return HttpResponse("delete_success")
    else:
        return HttpResponse("delete_fail")


@csrf_exempt
def reportedUsers(request):
    print("GET request received: reportedUsers")

    # Connect to db and search for users with reports
    db = client['tootaloo']
    user_collection = db['users']

    users = user_collection.find({"reports": {"$gt": 0}}).limit(40)
    print(users)

    # Return response
    resp = HttpResponse(dumps(users, sort_keys=True,
                              indent=4, default=json_util.default))
    resp['Content-Type'] = 'application/json'

    return resp


def userById(request):
    user_id = ObjectId(request.GET.get('user_id', ''))

    db = client['tootaloo']
    users_collection = db['users']
    user = users_collection.find_one({'_id': user_id})
    print(user)

    response = {'status': "success", 'user': user}
    resp = HttpResponse(dumps(response, sort_keys=True,
                              indent=4, default=json_util.default))
    resp['Content-Type'] = 'application/json'
    return resp


@csrf_exempt
def favoriteRestroom(request):
    user_id = ObjectId(request.GET.get('user_id', ''))
    restroom_id = ObjectId(request.GET.get('restroom_id', ''))

    db = client['tootaloo']
    users_collection = db['users']
    id_query = {'_id': user_id}
    new_restrooms = {'$push': {'favorite_restrooms': restroom_id}}
    users_collection.update_one(id_query, new_restrooms)

    user = users_collection.find_one({'_id': user_id})
    response = {'response': "success", "user": user}
    resp = HttpResponse(dumps(response, sort_keys=True,
                              indent=4, default=json_util.default))
    resp['Content-Type'] = 'application/json'
    return resp


@csrf_exempt
def unfavoriteRestroom(request):
    user_id = ObjectId(request.GET.get('user_id', ''))
    restroom_id = ObjectId(request.GET.get('restroom_id', ''))

    db = client['tootaloo']
    users_collection = db['users']

    try:
        result = users_collection.update_one(
            {'_id': user_id}, {'$pull': {'favorite_restrooms': restroom_id}})
        resp = HttpResponse(dumps(
            {"response": "success"}, sort_keys=True, indent=4, default=json_util.default))
        resp['Content-Type'] = 'application/json'
        return resp
    except pymongo.errors.PyMongoError as e:
        resp = HttpResponse(dumps(
            {"response": "failure"}, sort_keys=True, indent=4, default=json_util.default))
        resp['Content-Type'] = 'application/json'
        return resp


@csrf_exempt
def reportedRatings(request):
    print("GET request received: reported-ratings")

    db = client['tootaloo']
    ratings_collection = db['ratings']

    ratings_data = ratings_collection.find({"reports": {"$gt": 0}}).limit(40)

    print(ratings_data)
    ratingsRet = []
    for rating in ratings_data:
        ratingsRet.append(rating)

    resp = HttpResponse(dumps(ratingsRet, sort_keys=True,
                              indent=4, default=json_util.default))
    resp['Content-Type'] = 'application/json'

    return resp
