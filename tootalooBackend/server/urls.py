from django.urls import path

from . import views

urlpatterns = [
  path('', views.index, name='index'), 
  path('buildings/', views.buildings, name='buildings'),
  path('ratings-by-ids/', views.ratingsByIds, name='ratings-by-ids'),
  path('restrooms/', views.restrooms, name='restrooms'),
]
