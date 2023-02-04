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

#PyMongo client
client = pymongo.MongoClient(env('MONGODB_CONNECTION_STRING'), tlsCAFile=certifi.where(), serverSelectionTimeoutMS=5000)

# TODO: delete below later
# trying connection with MongoDB with sample data
dbname = client['sample_db']
collection = dbname['sample_collection']

route_1 = {
	"rating": "good",
	"location": "here"
}

collection.insert_one(route_1)

review_details = collection.find({})

# for r in route_details:
# 	print("src_airport")
# 	print(r['src_airport'])
# 	print("dest_airport")
# 	print(r['dst_airport'])

def index(request):
		return HttpResponse(review_details)
    #return HttpResponse("<h1>Hello and welcome to <u>Tootaloo</u></h1>")



