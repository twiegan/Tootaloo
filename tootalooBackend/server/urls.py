from django.urls import path

from . import views

urlpatterns = [
  path('', views.index, name='index'), 
  path('buildings/', views.buildings, name='buildings'),
  path('ratings/', views.ratings, name='ratings'),
  path('restrooms/', views.restrooms, name='restrooms'),
]
