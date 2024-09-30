## Learning Docker

In the Dockerfile: 
FROM node:alpine note: apline is a linux system 
COPY . /app
WORKDIR /app  
CMD node app.js

- in CMD: docker build -t hello-docker .
- in CMD: docker run hello-docker

- Linux using ubuntu distro:
> docker run -it ubuntu
> docker ps -a  : to find what containers are running on docker
> linux commands: 
- echo hello 
- whoami
- history
- !2
- pwd 
- ls 
- ls -1
- ls -l
- ls /
- cd ~
- ls /root
- mkdir test
- to move or change the name of a file and directory: mv 
- create file: touch 
- remove: rm 
- remove directory: rm -r
- nano file1.txt
- to see the contents of the file: cat or more 

Package manger in Linux
- apt or apt-get
- apt update 
- apt list
- apt install nano 
- apt remove nano
- apt install python3


### Pulling Database

##### Postgres

- docker pull postgres 

> How to run Postgres 
- $ docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -d library/postgres

> Shorten version: 
- docker run -e POSTGRES_PASSWORD=mysecretpassword library/postgres

> Using old versions of postgres and giving it a name: 
- docker run --name postgres-old -e POSTGRES_PASSWORD=mysecretpassword -d postgres:13.16 

> To stop a Container: 
- docker container stop <name_of_container or id>

> To remove all containers at once
- docker container prune

##### Mongo

- docker pull mongo
- $ docker run --name some-mongo -d mongo:tag

> To Set the Port: 
- docker run --name mongo-two -p 4000:27017 -d mongo

##### Networking with Mongo & Mongo-Express

> Network Set-up
- Create the network: 
docker network create mongo-network

- Run the Code:
docker run --name mongodb 
-e MONGO_INITDB_ROOT_USERNAME=admin 
-e MONGO_INITDB_ROOT_PASSWORD=password 
--net mongo-network -p 27017:27017 -d mongo


> To link the networks together:
- docker run -d `
-p 8081:8081 `
-e ME_CONFIG_MONGODB_ADMINUSERNAME=admin `
-e ME_CONFIG_MONGODB_ADMINPASSWORD=password `
-e ME_CONFIG_MONGODB_SERVER=mongodb `
--net mongo-network `
--name mongo-express `
mongo-express
>> Note: read the log for the password !!!!
>> Note: use (` for powershell) and (\ for linux)

### Docker Compose 
> After creating the docker-compose.yaml file: 
- Run: docker-compose -f docker-compose.yaml up
- To remove: docker-compose -f docker-compose.yaml down 


### Creating image & container a Flask helloworld with Python
> First checkout the folder the you created:
> more info:
> Creating a “Hello, World!” application with Flask is a great way to get started with this micro web framework. Here’s a quick guide:

Install Flask: Make sure you have Flask installed. You can install it using pip:
pip install Flask

Create a minimal Flask application: Create a new Python file, for example, hello.py, and add the following code:
```Python

from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!'

if (__name__ == '__main__':)
    app.run()
```
> Run the application: Set the FLASK_APP environment variable and run the application:
```py
export FLASK_APP=hello.py
flask run
```

On Windows, use:
```py
$env:FLASK_APP = "hello.py"
flask run
```

Access the application: Open your web browser and go to (http://127.0.0.1:5000/). You should see “Hello, World!” displayed.

> To build on docker:
- docker build -t ganil151/hey-python-flask:0.0.1.RELEASE .

> To Run on docker: 
- docker container run -d -p 3000:3000 ganil151/hey-python-flask:0.0.1.RELEASE

> To add container on DockerHub:
- docker push ganil151/hey-python-flask:0.0.1.RELEASE

### Creating Image on Docker container on NodeJS

> Create a Package.json
> Run code: 
- npm init -y 
> create a index.js file
> import: npm i express
> Remove node modules
> Create Dockerfile
> Run code to build:
- docker build -t ganil151/hey-nodejs:0.0.1.RELEASE .
- docker push ganil151/hey-nodejs:0.0.1.RELEASE




[Link:](https://youtu.be/rr9cI4u1_88)






