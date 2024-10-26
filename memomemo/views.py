from django.shortcuts import render
from django.http import JsonResponse
from django.urls import reverse
from django.shortcuts import HttpResponse, HttpResponseRedirect, render
from .models import Task
from .forms import TaskForm
import datetime 

# Create your views here.
def index (request):
    tasks = Task.objects.all()
    return render(request, "memomemo/index.html", {
        "tasks": tasks
    })

def new(request):
    if request.method == "POST":
        new_task = TaskForm(request.POST)
        new_task.save()
        return HttpResponseRedirect(reverse("index"))
    else:
        form = TaskForm()
        return render(request, "memomemo/new.html", {
            "form": form,
        })
    
def delete(request):
    if request.method != "POST":
        return HttpResponseRedirect(reverse("index"))
    else:
        task = Task.objects.get(pk=request.POST['task_pk'])
        print(task)
        task.delete()
        return HttpResponseRedirect(reverse("index"))

def complete(request):
    if request.method != "POST":
        return HttpResponseRedirect(reverse("index"))
    else:
        task = Task.objects.get(pk=request.POST['task_pk'])
        if task.completed:
            task.completed = False
            task.completed_at = None
        else:
            task.completed = True
            task.completed_at = datetime.datetime.now()
        task.save()
        return HttpResponseRedirect(reverse("index"))
    
def edit(request):
    if request.method == "GET":
        task_pk = request.GET['task_pk']
        task = Task.objects.get(pk=task_pk)
        form = TaskForm(instance=task)
        return render(request, "memomemo/edit.html", {
            "form": form,
            "task_pk": task_pk,
        })
    else:
        task = Task.objects.get(pk=request.POST['task_pk'])
        task.task = request.POST['task']
        task.assignee = request.POST['assignee']
        task.save()
        return HttpResponseRedirect(reverse("index"))