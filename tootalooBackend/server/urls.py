from django.urls import path

from . import views

urlpatterns = [
  path('', views.index, name='index'), 
  path('buildings/', views.buildings, name='buildings'),
  path('restrooms/', views.restrooms, name='restrooms'),
  path('ratings/', views.ratings, name='ratings'),
  path('following_ratings/', views.following_ratings, name='following_ratings'),
  path('summary_ratings_building/', views.summary_ratings_building, name='summary_ratings_building'),
  path('submit_rating/', views.submit_rating, name='submit_raitng'),
  path('login/', views.login, name='login'),
]
