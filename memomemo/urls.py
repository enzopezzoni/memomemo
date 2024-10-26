from django.urls import path
from . import views

urlpatterns = [
    path("", views.index, name="index"),
    path("new", views.new, name="new"),
    path("delete", views.delete, name="delete"),
    path("edit", views.edit, name="edit"),
    path("complete", views.complete, name="complete"),
]