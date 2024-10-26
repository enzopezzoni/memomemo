from django.db import models

# Create your models here.

class Task(models.Model):
    ASSIGNEE_CHOICES = [
        ("Anthony", "Anthony"),
        ("Ilya", "Ilya"),
        ("Robert", "Robert"),
        ("Stella", "Stella"),
        ("Enzo", "Enzo"),
    ]
    assignee = models.CharField(max_length=16, choices=ASSIGNEE_CHOICES, default="Enzo")
    task = models.CharField(max_length=256, default="New task")
    created_at = models.DateTimeField(auto_now_add=True, editable=False)
    updated_at = models.DateTimeField(auto_now=True, editable=False)
    completed = models.BooleanField(default=False)
    completed_at = models.DateTimeField(editable=True, null=True)

    def __str__(self):
        return self.task