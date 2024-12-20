# Generated by Django 5.0.9 on 2024-10-25 17:59

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Task',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('assignee', models.CharField(choices=[('Anthony', 'Anthony'), ('Ilya', 'Ilya'), ('Robert', 'Robert'), ('Stella', 'Stella'), ('Enzo', 'Enzo')], default='Enzo', max_length=16)),
                ('task', models.CharField(default='New task', max_length=256)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('completed', models.BooleanField(default=False)),
            ],
        ),
    ]
