### Basic Container Operations
```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# List containers with size information
docker ps -s

# Start a container
docker start <container_name_or_id>

# Stop a container
docker stop <container_name_or_id>

# Restart a container
docker restart <container_name_or_id>

# Pause a container
docker pause <container_name_or_id>

# Unpause a container
docker unpause <container_name_or_id>

# Remove a container
docker rm <container_name_or_id>

# Remove a running container (force)
docker rm -f <container_name_or_id>

# Remove all stopped containers
docker container prune

# Remove all containers (stopped and running)
docker rm -f $(docker ps -aq)
```
___
### Container Inspection & Logs
```bash
# View container logs
docker logs <container_name_or_id>

# Follow log output (real-time)
docker logs -f <container_name_or_id>

# Show last 100 lines of logs
docker logs --tail 100 <container_name_or_id>

# Show logs with timestamps
docker logs -t <container_name_or_id>

# Show logs from last 10 minutes
docker logs --since 10m <container_name_or_id>

# Inspect container details (JSON format)
docker inspect <container_name_or_id>

# Get specific information (e.g., IP address)
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container_name_or_id>

# Get container's environment variables
docker inspect -f '{{.Config.Env}}' <container_name_or_id>

# Show container resource usage statistics
docker stats

# Show stats for specific container
docker stats <container_name_or_id>

# Show stats once (no stream)
docker stats --no-stream
```
___
### Execute Commands in Running Containers
```bash
# Execute command in running container
docker exec <container_name_or_id> <command>

# Interactive shell access (bash)
docker exec -it <container_name_or_id> bash

# Interactive shell access (sh - for Alpine)
docker exec -it <container_name_or_id> sh

# Execute command as root user
docker exec -u root -it <container_name_or_id> bash

# Execute command in specific working directory
docker exec -w /app -it <container_name_or_id> bash

# Run command and exit
docker exec <container_name_or_id> cat /etc/os-release
```
___
### Container File Operations
```bash
# Copy file from container to host
docker cp <container_name_or_id>:/path/in/container /path/on/host

# Copy file from host to container
docker cp /path/on/host <container_name_or_id>:/path/in/container

# Copy directory from container
docker cp <container_name_or_id>:/app/logs ./local-logs
```

---

## Docker Image Management

### Image Operations
```bash
# List images
docker images

# List all images (including intermediate)
docker images -a

# Pull an image from registry
docker pull <image_name>:<tag>

# Pull specific version
docker pull mysql:8.4.5

# Build image from Dockerfile
docker build -t <image_name>:<tag> .

# Build with no cache
docker build --no-cache -t <image_name>:<tag> .

# Build with custom Dockerfile
docker build -f Dockerfile.custom -t <image_name>:<tag> .

# Tag an image
docker tag <source_image>:<tag> <target_image>:<tag>

# Push image to registry
docker push <image_name>:<tag>

# Remove an image
docker rmi <image_name_or_id>

# Remove image forcefully
docker rmi -f <image_name_or_id>

# Remove all unused images
docker image prune

# Remove all images
docker rmi $(docker images -q)

# Inspect image details
docker inspect <image_name>:<tag>

# View image history/layers
docker history <image_name>:<tag>

# Save image to tar file
docker save -o image.tar <image_name>:<tag>

# Load image from tar file
docker load -i image.tar
```

---

## **Docker Network Management**

### Network Operations
```bash
# List networks
docker network ls

# Inspect network details
docker network inspect <network_name>

# Create a network
docker network create <network_name>

# Create network with custom subnet
docker network create --subnet=172.18.0.0/16 <network_name>

# Connect container to network
docker network connect <network_name> <container_name>

# Disconnect container from network
docker network disconnect <network_name> <container_name>

# Remove network
docker network rm <network_name>

# Remove all unused networks
docker network prune

# Create bridge network
docker network create --driver bridge <network_name>

# View container's network settings
docker inspect -f '{{json .NetworkSettings.Networks}}' <container_name> | jq
```

---

## **Docker Volume Management**

### Volume Operations
```bash
# List volumes
docker volume ls

# Create a volume
docker volume create <volume_name>

# Inspect volume
docker volume inspect <volume_name>

# Remove volume
docker volume rm <volume_name>

# Remove all unused volumes
docker volume prune

# Remove all volumes (dangerous!)
docker volume rm $(docker volume ls -q)

# Find which containers use a volume
docker ps -a --filter volume=<volume_name>
```

---

## **Docker Compose Commands**

### Compose Operations
```bash
# Start services in background
docker-compose up -d

# Start services in foreground
docker-compose up

# Start specific service
docker-compose up -d <service_name>

# Build images before starting
docker-compose up -d --build

# Force recreate containers
docker-compose up -d --force-recreate

# Stop services
docker-compose stop

# Stop specific service
docker-compose stop <service_name>

# Start stopped services
docker-compose start

# Restart services
docker-compose restart

# Restart specific service
docker-compose restart <service_name>

# Stop and remove containers, networks
docker-compose down

# Stop and remove everything including volumes
docker-compose down -v

# View service logs
docker-compose logs

# Follow logs for specific service
docker-compose logs -f <service_name>

# View logs for last 100 lines
docker-compose logs --tail=100

# List running services
docker-compose ps

# List all services (including stopped)
docker-compose ps -a

# Execute command in service
docker-compose exec <service_name> <command>

# Execute with shell access
docker-compose exec <service_name> bash

# View service configuration
docker-compose config

# Validate docker-compose.yml
docker-compose config --quiet

# Pull images defined in compose file
docker-compose pull

# Build services
docker-compose build

# Build without cache
docker-compose build --no-cache

# Scale services
docker-compose up -d --scale <service_name>=3

# View service resource usage
docker-compose top
```

---
## **Docker System Management**

### System Operations
```bash
# Show Docker disk usage
docker system df

# Detailed disk usage
docker system df -v

# Remove all unused data (containers, networks, images)
docker system prune

# Prune everything including volumes
docker system prune -a --volumes

# Show system-wide information
docker info

# Show Docker version
docker version

# Monitor Docker events in real-time
docker events

# Show events for last 10 minutes
docker events --since 10m

# Show events with filters
docker events --filter 'event=stop'
```

---
## **Diagnostic Commands**

### Container Health Diagnostics
```bash
# Check container health status
docker inspect --format='{{.State.Health.Status}}' <container_name>

# View health check logs
docker inspect --format='{{json .State.Health}}' <container_name> | jq

# Check if container is running
docker inspect -f '{{.State.Running}}' <container_name>

# Get container exit code
docker inspect -f '{{.State.ExitCode}}' <container_name>

# Check container start time
docker inspect -f '{{.State.StartedAt}}' <container_name>

# View container restart count
docker inspect -f '{{.RestartCount}}' <container_name>
```

### Network Diagnostics
```bash
# Test connectivity between containers
docker exec <container1> ping <container2>

# Test DNS resolution
docker exec <container_name> nslookup <hostname>

# Check open ports in container
docker exec <container_name> netstat -tuln

# Alternative for minimal containers
docker exec <container_name> ss -tuln

# Test connection to specific port
docker exec <container_name> nc -zv <host> <port>

# Check container's IP address
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container_name>

# View all containers in a network
docker network inspect <network_name> -f '{{range .Containers}}{{.Name}} {{end}}'

# Trace network route
docker exec <container_name> traceroute <destination>

# Test HTTP endpoint
docker exec <container_name> curl -I http://localhost:8080
```

### Resource Usage Diagnostics

bash

```bash
# Real-time container stats
docker stats <container_name>

# Check memory usage
docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}"

# Check CPU usage
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}"

# View processes running in container
docker top <container_name>

# View processes with custom format
docker top <container_name> aux

# Check disk I/O
docker stats --format "table {{.Container}}\t{{.BlockIO}}"
```
___
### Log 
```bash
# Search logs for specific term
docker logs <container_name> 2>&1 | grep -i "error"

# Count error occurrences
docker logs <container_name> 2>&1 | grep -i "error" | wc -l

# Export logs to file
docker logs <container_name> > container.log 2>&1

# View logs between timestamps
docker logs --since "2025-01-01T00:00:00" --until "2025-01-01T23:59:59" <container_name>

# Show only stderr logs
docker logs <container_name> 2>&1 >/dev/null

# Monitor logs with keyword highlighting
docker logs -f <container_name> | grep --color=always -i "error\|warning"
```
___
### Application-Specific Diagnostics (Spring Boot)
```bash
# Check Spring Boot actuator health
docker exec <container_name> curl http://localhost:8080/actuator/health

# Check application info
docker exec <container_name> curl http://localhost:8080/actuator/info

# View environment variables
docker exec <container_name> curl http://localhost:8080/actuator/env

# Check metrics
docker exec <container_name> curl http://localhost:8080/actuator/metrics

# Thread dump
docker exec <container_name> curl http://localhost:8080/actuator/threaddump

# Heap dump
docker exec <container_name> curl http://localhost:8080/actuator/heapdump -o heapdump.hprof
```
___
### Database Diagnostics (MySQL Container)
```bash
# Connect to MySQL
docker exec -it <mysql_container> mysql -u root -p

# Check MySQL process list
docker exec <mysql_container> mysql -u root -p -e "SHOW PROCESSLIST;"

# Check database status
docker exec <mysql_container> mysql -u root -p -e "SHOW STATUS;"

# Check MySQL variables
docker exec <mysql_container> mysql -u root -p -e "SHOW VARIABLES;"

# Backup database
docker exec <mysql_container> mysqldump -u root -p<password> <database> > backup.sql

# Check MySQL error log
docker exec <mysql_container> cat /var/log/mysql/error.log
```
___
### Docker Daemon Diagnostics
```bash
# Check Docker service status (Linux)
sudo systemctl status docker

# View Docker daemon logs (Linux)
sudo journalctl -u docker.service

# View recent Docker daemon logs
sudo journalctl -u docker.service --since "1 hour ago"

# Check Docker daemon configuration
cat /etc/docker/daemon.json

# Restart Docker daemon
sudo systemctl restart docker
```

---

## **Performance & Troubleshooting**

### Container Performance Analysis
```bash
# Monitor container in real-time with detailed stats
docker stats --all --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# Check container resource limits
docker inspect -f '{{.HostConfig.Memory}}' <container_name>
docker inspect -f '{{.HostConfig.CpuShares}}' <container_name>

# View container's port mappings
docker port <container_name>

# Check container changes (files modified)
docker diff <container_name>
```
___
### Network Troubleshooting
```bash
# Install network tools in container (if needed)
docker exec <container_name> apt-get update && apt-get install -y iputils-ping net-tools curl

# For Alpine-based images
docker exec <container_name> apk add --no-cache curl netcat-openbsd bind-tools

# Test DNS from container
docker exec <container_name> dig google.com
docker exec <container_name> nslookup google.com

# Check routing table
docker exec <container_name> route -n

# List network interfaces
docker exec <container_name> ip addr show
```
___

### Cleanup Commands

bash

```bash
# Clean everything (be careful!)
docker system prune -a --volumes -f

# Remove only stopped containers
docker container prune -f

# Remove only dangling images
docker image prune -f

# Remove only unused volumes
docker volume prune -f

# Remove only unused networks
docker network prune -f

# Remove containers older than 24 hours
docker container prune --filter "until=24h"
```

---

## **Quick Diagnostic Script**

Save this as `docker-diagnose.sh`:
```bash
#!/bin/bash

echo "=== Docker System Info ==="
docker info | grep -E 'Server Version|Storage Driver|Logging Driver|Cgroup Driver|Kernel Version'

echo -e "\n=== Disk Usage ==="
docker system df

echo -e "\n=== Running Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo -e "\n=== Container Resource Usage ==="
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

echo -e "\n=== Docker Networks ==="
docker network ls

echo -e "\n=== Recent Container Logs (Errors) ==="
for container in $(docker ps -q); do
    name=$(docker inspect -f '{{.Name}}' $container | sed 's/\///')
    echo "--- $name ---"
    docker logs --tail 20 $container 2>&1 | grep -i "error\|exception\|fatal" | head -5
done

echo -e "\n=== Container Health Status ==="
for container in $(docker ps -q); do
    name=$(docker inspect -f '{{.Name}}' $container | sed 's/\///')
    health=$(docker inspect -f '{{.State.Health.Status}}' $container 2>/dev/null || echo "no healthcheck")
    echo "$name: $health"
done
```

Make it executable:
```bash
chmod +x docker-diagnose.sh
./docker-diagnose.sh
```
___
## **Common Troubleshooting Scenarios**

### Scenario 1: Container Keeps Restarting
```bash
# Check exit code
docker inspect -f '{{.State.ExitCode}}' <container_name>

# View recent logs
docker logs --tail 50 <container_name>

# Check restart policy
docker inspect -f '{{.HostConfig.RestartPolicy}}' <container_name>

# Disable restart temporarily
docker update --restart=no <container_name>
```
___
### Scenario 2: Container Cannot Connect to Network
```bash
# Check container's network
docker inspect -f '{{range.NetworkSettings.Networks}}{{.NetworkID}}{{end}}' <container_name>

# Check IP address
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container_name>

# Test ping between containers
docker exec <container1> ping -c 3 <container2>

# Check DNS resolution
docker exec <container_name> nslookup <service_name>
```
___
### Scenario 3: Out of Disk Space
```bash
# Check disk usage
docker system df -v

# Clean up
docker system prune -a --volumes

# Find large containers
docker ps -s

# Find large images
docker images --format "{{.Repository}}:{{.Tag}}\t{{.Size}}" | sort -k2 -h
```

This comprehensive guide should cover most Docker operations and diagnostic needs for your Spring Petclinic setup!
