from django.urls import path

from . import views

urlpatterns = [
  path('', views.index, name='index'), 
  path('buildings/', views.buildings, name='buildings'),
  path('ratings-by-ids/', views.ratingsByIds, name='ratings-by-ids'),
  path('restrooms-by-building-and-floor/', views.restroomsByBuildingAndFloor, name='restrooms-by-building-and-floor'),
  path('user-by-username/', views.userByUsername, name='user-by-username'),
  path('follow-user-by-username/', views.followUserByUsername, name='follow-user-by-username'),
  path('unfollow-user-by-username/', views.unfollowUserByUsername, name='unfollow-user-by-username'),
  path('restrooms/', views.restrooms, name='restrooms'),
  path('ratings/', views.ratings, name='ratings'),
  path('following_ratings/', views.following_ratings, name='following_ratings'),
  path('summary_ratings_building/', views.summary_ratings_building, name='summary_ratings_building'),
  path('submit_rating/', views.submit_rating, name='submit_raitng'),
  path('login/', views.login, name='login'),
  path('user_register/', views.user_register, name='user_register'),
  path('save_user_settings/', views.save_user_settings, name='save_user_settings'),
]
