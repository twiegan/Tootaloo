from django.urls import path

from . import views

urlpatterns = [
  path('', views.index, name='index'), 
  path('buildings/', views.buildings, name='buildings'),
  path('ratings-by-ids/', views.ratingsByIds, name='ratings-by-ids'),
  path('restrooms/', views.restrooms, name='restrooms'),
  path('user-by-username/', views.userByUsername, name='user-by-username'),
  path('follow-user-by-username/', views.followUserByUsername, name='follow-user-by-username'),
  path('unfollow-user-by-username/', views.unfollowUserByUsername, name='unfollow-user-by-username')
]
