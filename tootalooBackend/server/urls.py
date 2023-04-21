from django.urls import path

from . import views

urlpatterns = [
  path('', views.index, name='index'), 
  path('buildings/', views.buildings, name='buildings'),
  path('ratings-by-ids/', views.ratingsByIds, name='ratings-by-ids'),
  path('rating_by_id/', views.rating_by_id, name='rating_by_id'),
  path('restrooms-by-building-and-floor/', views.restroomsByBuildingAndFloor, name='restrooms-by-building-and-floor'),
  path('user-by-username/', views.userByUsername, name='user-by-username'),
  path('follow-user-by-username/', views.followUserByUsername, name='follow-user-by-username'),
  path('unfollow-user-by-username/', views.unfollowUserByUsername, name='unfollow-user-by-username'),
  path('check-following-by-username/', views.checkFollowingByUsername, name='check-following-by-username'),
  path('restrooms/', views.restrooms, name='restrooms'),
  path('ratings/', views.ratings, name='ratings'),
  path('following_ratings/', views.following_ratings, name='following_ratings'),
  path('update_votes/', views.update_votes, name='update_votes'),
  path('summary_ratings_building/', views.summary_ratings_building, name='summary_ratings_building'),
  path('submit_rating/', views.submit_rating, name='submit_raitng'),
  path('edit_rating/', views.edit_rating, name='edit_raitng'),
  path('login/', views.login, name='login'),
  path('user_register/', views.user_register, name='user_register'),
  path('save_user_settings/', views.save_user_settings, name='save_user_settings'),
  path('check_votes/', views.check_votes, name='check_votes'),
  path('post_owned/', views.post_owned, name='post_owned'),
  path('insert_user/', views.insert_user, name='insert_user'),
  path('check-reported/', views.checkReported, name='check-reported'),
  path('update-reports/', views.updateReports, name='update-reports'),
]
