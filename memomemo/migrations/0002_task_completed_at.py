# Generated by Django 5.0.9 on 2024-10-25 20:21

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('memomemo', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='task',
            name='completed_at',
            field=models.DateTimeField(null=True),
        ),
    ]
