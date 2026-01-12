```bash
[cent@dlp ~]$ python3 -m venv --system-site-packages ~/django

[cent@dlp ~]$ source ~/django/bin/activate

(django) [cent@dlp ~]$ pip3 install 'Django>=4,<5'
 Collecting Django<5,>=4
  Downloading Django-4.2.13-py3-none-any.whl (8.0 MB)
Collecting sqlparse>=0.3.1
  Downloading sqlparse-0.5.0-py3-none-any.whl (43 kB)
Collecting asgiref<4,>=3.6.0
  Downloading asgiref-3.8.1-py3-none-any.whl (23 kB)
Collecting typing-extensions>=4
  Downloading typing_extensions-4.12.1-py3-none-any.whl (37 kB)
Installing collected packages: typing-extensions, sqlparse, asgiref, Django
Successfully installed Django-4.2.13 asgiref-3.8.1 sqlparse-0.5.0 typing-extensions-4.12.1
WARNING: You are using pip version 21.3.1; however, version 24.0 is available.
You should consider upgrading via the '/home/cent/django/bin/python3 -m pip install --upgrade pip' command.

(django) [cent@dlp ~]$ django-admin --version
4.2.13

# to exit from venv, run like follows
(django) [cent@dlp ~]$ deactivate
```

#### Create a test project.  
If Firewalld is running and also access to Django from other Hosts, Allow ports you plan to use with root privilege before it. (example below uses [8000/tcp])

```bash
[cent@dlp ~]$ source ~/django/bin/activate

# create testproject  
(django) [cent@dlp ~]$ django-admin startproject testproject
  
(django) [cent@dlp ~]$ 
[cd](https://www.server-world.info/en/command/html/cd.html) testproject

# configure database (default is SQLite)  
(django) [cent@dlp testproject]$ python manage.py migrate

# create admin user  
(django) [cent@dlp testproject]$ python manage.py createsuperuser
  
Username (leave blank to use 'cent'): 

cent

  
Email address: 

cent@dlp.srv.world

  
Password:  
Password (again):  
Superuser created successfully.

(django) [cent@dlp testproject]$ 

[vi](https://www.server-world.info/en/command/html/vi.html) testproject/settings.py

# line 28 : set if you allow to access to Django from other Hosts  
# specify Hosts with comma separated  
# if allow all, specify like follows

  
ALLOWED_HOSTS = [

'*'

]

# start server

  
(django) [cent@dlp testproject]$ 

python manage.py runserver 0.0.0.0:8000

  

Watching for file changes with StatReloader
Performing system checks...

System check identified no issues (0 silenced).
June 04, 2024 - 08:13:53
Django version 4.2.13, using settings 'testproject.settings'
Starting development server at http://0.0.0.0:8000/
Quit the server with CONTROL-C.
```

|     |
| --- |

|   |   |
|---|---|
|[4]|Access to the [(server's hostname or IP address):8000/] from a client computer. It's OK if following site is displayed normally.|

|   |
|---|
|![](https://www.server-world.info/en/CentOS_Stream_9/python/img/2.png)|

|   |   |
|---|---|
|[5]|It's possible to use admin site on [(server's hostname or IP address):8000/admin].|

|   |
|---|
|![](https://www.server-world.info/en/CentOS_Stream_9/python/img/2.png)|
|![](https://www.server-world.info/en/CentOS_Stream_9/python/img/3.png)|

|   |   |
|---|---|
|[6]|Create a test application to try to use Django.|

|   |
|---|
|[cent@dlp ~]$ <br><br>source ~/django/bin/activate<br><br>(django) [cent@dlp ~]$ <br><br>[cd](https://www.server-world.info/en/command/html/cd.html) testproject<br><br>  <br><br>(django) [cent@dlp testproject]$ <br><br>python manage.py startapp test_app<br><br>  <br><br>(django) [cent@dlp testproject]$ <br><br>[vi](https://www.server-world.info/en/command/html/vi.html) test_app/views.py<br><br># add to last line<br><br>  <br><br>from django.http import HttpResponse<br>def main(request):<br>    html = '<html>\n' \<br>           '<body>\n' \<br>           '<p style="width: 100%; font-size: 40px; font-weight: bold; text-align: center;">\n' \<br>           'Django Test Page\n' \<br>           '</p>\n' \<br>           '</body>\n' \<br>           '</html>\n'<br>    return HttpResponse(html)<br><br>(django) [cent@dlp testproject]$ <br><br>[vi](https://www.server-world.info/en/command/html/vi.html) testproject/urls.py<br><br># line 17, 21 : add like follows<br><br>  <br><br>from django.contrib import admin<br>from django.urls import path, include<br><br>urlpatterns = [<br>    path('admin/', admin.site.urls),<br>    path('test_app/', include('test_app.urls')),<br>]<br><br>(django) [cent@dlp testproject]$ <br><br>[vi](https://www.server-world.info/en/command/html/vi.html) test_app/urls.py<br><br># create new<br><br>  <br><br>from django.urls import path<br>from .views import main<br><br>urlpatterns = [<br>    path('', main, name='home')<br>]<br><br>(django) [cent@dlp testproject]$ <br><br>[vi](https://www.server-world.info/en/command/html/vi.html) testproject/settings.py<br><br># line 33 : add test application in [INSTALLED_APPS] section<br><br>  <br><br>INSTALLED_APPS = (<br>    'django.contrib.admin',<br>    'django.contrib.auth',<br>    'django.contrib.contenttypes',<br>    'django.contrib.sessions',<br>    'django.contrib.messages',<br>    'django.contrib.staticfiles',<br>    'test_app',<br>)<br><br>(django) [cent@dlp testproject]$ <br><br>python manage.py runserver 0.0.0.0:8000|

|   |   |
|---|---|
|[7]|Access to the [(server's hostname or IP address):8000/testapp/] from a client computer. It's OK if testapp is displayed normally.|

|   |
|---|
|![](https://www.server-world.info/en/CentOS_Stream_9/python/img/4.png)|