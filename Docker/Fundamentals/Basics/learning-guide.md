# Docker Learning Guide

Comprehensive step-by-step guide to learning Docker from basics to advanced concepts.

## Learning Path Overview

```
Basics → Images → Containers → Networking → Storage → Security → Production
  ↓        ↓        ↓           ↓           ↓         ↓          ↓
Setup   Build    Manage     Connect     Persist   Secure    Deploy
```

## Getting Started

### What is Docker?

Docker is a containerization platform that packages applications and their dependencies into lightweight, portable containers.

**Key Benefits:**
- **Consistency**: Same environment everywhere
- **Portability**: Run anywhere Docker is installed
- **Efficiency**: Lightweight compared to VMs
- **Scalability**: Easy to scale applications
- **Isolation**: Applications run in isolated environments

### Basic Docker Workflow

```
Write Code → Create Dockerfile → Build Image → Run Container
     ↓              ↓              ↓            ↓
  app.js      FROM node:alpine   docker build  docker run
```

## Hands-On Learning Exercises

### Exercise 1: Your First Container

```bash
# Pull and run a simple container
docker run hello-world

# Run an interactive container
docker run -it ubuntu bash

# Inside the container, try these Linux commands:
echo "Hello Docker!"
whoami
pwd
ls /
cd ~
mkdir test
touch file1.txt
```

**What you learned:**
- How to run containers
- Container isolation
- Basic Linux commands in containers

### Exercise 2: Working with Alpine Linux

```bash
# Run Alpine Linux (minimal distribution)
docker run -it alpine

# Inside Alpine, explore the system:
echo "hello"
whoami
history
pwd
ls -1
ls -l
ls /
cd ~
mkdir test
```

**Alpine Benefits:**
- Very small size (~5MB)
- Security-focused
- Perfect for containers

### Exercise 3: Package Management in Containers

```bash
# Run Ubuntu container
docker run -it ubuntu

# Update package list and install software:
apt update
apt list
apt install nano
apt install python3

# Try the installed software:
python3 --version
nano --version

# Remove packages:
apt remove nano
```

**What you learned:**
- Package managers (apt, apk)
- Installing software in containers
- Container filesystem changes

## Building Your First Application

### Exercise 4: Node.js Hello World

Create a simple Node.js application:

```javascript
// app.js
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello Docker World!');
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});
```

```json
// package.json
{
  "name": "docker-hello-world",
  "version": "1.0.0",
  "description": "Simple Docker app",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
```

```dockerfile
# Dockerfile
FROM node:alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

```bash
# Build and run:
docker build -t hello-node .
docker run -p 3000:3000 hello-node

# Test the application:
curl http://localhost:3000
```

### Exercise 5: Python Flask Application

Based on the Old_Projects example, create a Flask app:

```python
# index.py
from flask import Flask

helloworld = Flask(__name__)

@helloworld.route("/")  
def run():
    return "{\"message\":\"Hey there Python\"}"

if __name__ == "__main__":
    helloworld.run(host="0.0.0.0", port=int("3000"), debug=True)
```

```txt
# requirements.txt
flask
```

```dockerfile
# Dockerfile
FROM python:3-alpine3.15
WORKDIR /app 
COPY . /app/
RUN pip install -r requirements.txt
EXPOSE 3000 
CMD python ./index.py
```

```bash
# Build and run:
docker build -t python-flask .
docker run -p 3000:3000 python-flask

# Tag for registry:
docker tag python-flask your-username/python-flask:v1.0
```

## Database Containers

### Exercise 6: PostgreSQL Database

```bash
# Run PostgreSQL container
docker run --name postgres-db \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -d postgres

# Connect to the database
docker exec -it postgres-db psql -U postgres

# Inside PostgreSQL:
CREATE DATABASE myapp;
\l
\q
```

### Exercise 7: MongoDB with Mongo Express

Set up MongoDB with a web interface:

```bash
# Create network for containers to communicate
docker network create mongo-network

# Run MongoDB
docker run --name mongodb \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=password \
  --net mongo-network \
  -p 27017:27017 \
  -d mongo

# Run Mongo Express (web UI)
docker run -d \
  -p 8081:8081 \
  -e ME_CONFIG_MONGODB_ADMINUSERNAME=admin \
  -e ME_CONFIG_MONGODB_ADMINPASSWORD=password \
  -e ME_CONFIG_MONGODB_SERVER=mongodb \
  --net mongo-network \
  --name mongo-express \
  mongo-express
```

**Access Mongo Express at:** http://localhost:8081

### Exercise 8: MySQL Database

```bash
# Run MySQL with custom settings
docker run --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=myapp \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=apppassword \
  -p 3306:3306 \
  -d mysql:8.0

# Connect to MySQL
docker exec -it mysql-db mysql -u root -p
```

## Docker Compose Learning

### Exercise 9: Multi-Container Application

Create a `docker-compose.yaml` file:

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DB_HOST=database
    depends_on:
      - database

  database:
    image: postgres:13
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
```

```bash
# Run the application stack:
docker-compose up

# Run in background:
docker-compose up -d

# View logs:
docker-compose logs

# Stop the stack:
docker-compose down

# Remove volumes too:
docker-compose down --volumes
```

## Container Management

### Exercise 10: Container Lifecycle

```bash
# List containers
docker ps                    # Running containers
docker ps -a                # All containers

# Start/stop containers
docker start <container>     # Start stopped container
docker stop <container>      # Graceful stop
docker kill <container>      # Force stop
docker restart <container>   # Restart container

# Remove containers
docker rm <container>        # Remove stopped container
docker rm -f <container>     # Force remove running container
docker container prune      # Remove all stopped containers
```

### Exercise 11: Container Inspection

```bash
# Get detailed container information
docker inspect <container>

# View container logs
docker logs <container>
docker logs -f <container>   # Follow logs
docker logs --tail 50 <container>

# Execute commands in running container
docker exec -it <container> bash
docker exec <container> ls /app

# Monitor resource usage
docker stats
docker stats <container>
```

## Image Management

### Exercise 12: Working with Images

```bash
# List images
docker images
docker image ls

# Pull images
docker pull nginx
docker pull nginx:1.21      # Specific version
docker pull ubuntu:20.04

# Remove images
docker rmi <image>
docker image rm <image>
docker image prune          # Remove unused images

# Image history and inspection
docker history <image>
docker inspect <image>
```

### Exercise 13: Building Optimized Images

```dockerfile
# Multi-stage build example
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:16-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
USER 1000:1000
EXPOSE 3000
CMD ["node", "server.js"]
```

## Registry Operations

### Exercise 14: Docker Hub Integration

```bash
# Login to Docker Hub
docker login

# Tag image for registry
docker tag myapp:latest username/myapp:latest
docker tag myapp:latest username/myapp:v1.0

# Push to Docker Hub
docker push username/myapp:latest
docker push username/myapp:v1.0

# Pull from registry
docker pull username/myapp:latest
```

## Networking Deep Dive

### Exercise 15: Custom Networks

```bash
# Create custom network
docker network create mynetwork
docker network create --subnet=172.20.0.0/16 mynetwork

# Run containers on custom network
docker run -d --name web --network mynetwork nginx
docker run -d --name db --network mynetwork postgres

# Test connectivity
docker exec web ping db
docker exec web nslookup db
```

### Exercise 16: Port Mapping Scenarios

```bash
# Different port mapping examples
docker run -p 8080:80 nginx              # Host:Container
docker run -p 127.0.0.1:8080:80 nginx    # Bind to specific interface
docker run -p 8080-8090:80 nginx         # Port range
docker run -P nginx                       # Publish all exposed ports

# Check port mappings
docker port <container>
netstat -tulpn | grep :8080
```

## Volume and Data Management

### Exercise 17: Data Persistence

```bash
# Named volumes
docker volume create mydata
docker run -v mydata:/data alpine

# Bind mounts
docker run -v $(pwd):/app nginx
docker run -v /host/path:/container/path nginx

# tmpfs mounts (memory-based)
docker run --tmpfs /tmp nginx
```

### Exercise 18: Backup and Restore

```bash
# Backup volume data
docker run --rm \
  -v myvolume:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/backup.tar.gz -C /data .

# Restore volume data
docker run --rm \
  -v myvolume:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/backup.tar.gz -C /data
```

## Security Fundamentals

### Exercise 19: Security Best Practices

```dockerfile
# Secure Dockerfile
FROM node:16-alpine

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Set working directory
WORKDIR /app

# Copy and install dependencies
COPY --chown=nextjs:nodejs package*.json ./
RUN npm ci --only=production

# Copy application
COPY --chown=nextjs:nodejs . .

# Switch to non-root user
USER nextjs

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:3000/health || exit 1

EXPOSE 3000
CMD ["node", "server.js"]
```

```bash
# Run with security options
docker run --read-only \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --user 1000:1000 \
  myapp
```

## Troubleshooting Practice

### Exercise 20: Common Issues

```bash
# Debug container that won't start
docker logs <container>
docker inspect <container>

# Debug networking issues
docker network inspect bridge
docker exec <container> ping <target>
docker exec <container> nslookup <hostname>

# Debug performance issues
docker stats <container>
docker exec <container> top
docker exec <container> free -h

# Clean up resources
docker system prune
docker system df
```

## Production Deployment

### Exercise 21: Production-Ready Setup

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  web:
    image: myapp:v1.0
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    environment:
      - NODE_ENV=production
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - web
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

## Learning Milestones

### Beginner Level ✅
- [ ] Understand containers vs VMs
- [ ] Run basic containers
- [ ] Build simple images
- [ ] Use basic Docker commands
- [ ] Work with volumes

### Intermediate Level 🎯
- [ ] Create multi-stage builds
- [ ] Use Docker Compose
- [ ] Understand networking
- [ ] Implement health checks
- [ ] Basic security practices

### Advanced Level 🚀
- [ ] Optimize image sizes
- [ ] Implement CI/CD pipelines
- [ ] Use orchestration tools
- [ ] Monitor containers
- [ ] Production deployment

## Next Steps

1. **Practice Projects**: Build real applications with Docker
2. **Learn Kubernetes**: Container orchestration at scale
3. **CI/CD Integration**: Automate Docker workflows
4. **Security Deep Dive**: Advanced container security
5. **Monitoring**: Implement comprehensive monitoring
6. **Cloud Deployment**: Deploy to cloud platforms

## Useful Commands Reference

### Container Operations
```bash
docker run [OPTIONS] IMAGE [COMMAND]
docker ps [-a]
docker stop/start/restart CONTAINER
docker rm [-f] CONTAINER
docker exec -it CONTAINER COMMAND
docker logs [-f] CONTAINER
```

### Image Operations
```bash
docker build -t NAME .
docker images
docker pull/push IMAGE
docker rmi IMAGE
docker tag SOURCE TARGET
```

### System Operations
```bash
docker system df
docker system prune [-a]
docker info
docker version
```

### Network Operations
```bash
docker network ls
docker network create NAME
docker network inspect NAME
docker network connect/disconnect
```

### Volume Operations
```bash
docker volume ls
docker volume create NAME
docker volume inspect NAME
docker volume rm NAME
```

## Resources for Continued Learning

- **Official Documentation**: https://docs.docker.com/
- **Docker Hub**: https://hub.docker.com/
- **Play with Docker**: https://labs.play-with-docker.com/
- **Docker Samples**: https://github.com/docker/awesome-compose
- **Best Practices**: https://docs.docker.com/develop/dev-best-practices/