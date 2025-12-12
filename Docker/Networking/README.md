# Docker Networking

Complete guide to Docker networking concepts, configurations, and best practices.

## Network Fundamentals

### Docker Network Types

- **Bridge**: Default network for containers on single host
- **Host**: Container uses host's network stack
- **None**: Container has no network access
- **Overlay**: Multi-host networking for Swarm
- **Macvlan**: Assign MAC address to container

### Network Architecture

```
Container A ←→ Bridge Network ←→ Container B
     ↓              ↓              ↓
Host Network ←→ Docker Daemon ←→ External Network
```

## Basic Network Operations

### Network Management

```bash
# List networks
docker network ls
docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"

# Inspect network
docker network inspect bridge
docker network inspect <network_name>

# Create network
docker network create mynetwork
docker network create --driver bridge mynetwork
docker network create --subnet=172.20.0.0/16 mynetwork

# Remove network
docker network rm mynetwork
docker network prune              # Remove unused networks
```

### Container Network Connection

```bash
# Run container on specific network
docker run --network mynetwork nginx
docker run --net=host nginx

# Connect running container to network
docker network connect mynetwork <container>
docker network disconnect mynetwork <container>

# Run with custom hostname
docker run --hostname webserver nginx
docker run --add-host myhost:192.168.1.100 nginx
```

## Network Drivers

### Bridge Network (Default)

```bash
# Create custom bridge network
docker network create \
  --driver bridge \
  --subnet=172.20.0.0/16 \
  --ip-range=172.20.240.0/20 \
  --gateway=172.20.0.1 \
  mybridge

# Run containers on bridge network
docker run -d --name web --network mybridge nginx
docker run -d --name db --network mybridge postgres
```

### Host Network

```bash
# Use host networking (Linux only)
docker run --network host nginx

# Container shares host's network stack
# No port mapping needed
# Direct access to host interfaces
```

### None Network

```bash
# No network access
docker run --network none alpine

# Useful for:
# - Security isolation
# - Batch processing
# - Testing scenarios
```

## Advanced Networking

### Custom Networks with Options

```bash
# Create network with custom options
docker network create \
  --driver bridge \
  --subnet=192.168.100.0/24 \
  --gateway=192.168.100.1 \
  --ip-range=192.168.100.128/25 \
  --opt com.docker.network.bridge.name=custom-bridge \
  --opt com.docker.network.bridge.enable_icc=true \
  --opt com.docker.network.bridge.enable_ip_masquerade=true \
  custom-network
```

### Static IP Assignment

```bash
# Assign static IP to container
docker run -d \
  --name web \
  --network custom-network \
  --ip 192.168.100.10 \
  nginx

# Multiple network connections
docker run -d \
  --name multi-net \
  --network network1 \
  nginx

docker network connect --ip 192.168.200.10 network2 multi-net
```

## Port Mapping and Exposure

### Port Publishing

```bash
# Basic port mapping
docker run -p 8080:80 nginx              # Host:Container
docker run -p 127.0.0.1:8080:80 nginx    # Bind to specific interface
docker run -p 8080-8090:80 nginx         # Port range

# Multiple port mappings
docker run -p 80:80 -p 443:443 nginx

# UDP port mapping
docker run -p 53:53/udp dns-server

# Random port assignment
docker run -P nginx                       # Publish all exposed ports
```

### Port Discovery

```bash
# Find mapped ports
docker port <container>
docker port <container> 80

# Inspect port mappings
docker inspect <container> | grep -i port
```

## Container Communication

### Name Resolution

```bash
# Containers can communicate by name on custom networks
docker network create app-network

docker run -d --name database --network app-network postgres
docker run -d --name webapp --network app-network \
  -e DB_HOST=database myapp

# Test connectivity
docker exec webapp ping database
docker exec webapp nslookup database
```

### Service Discovery

```bash
# Automatic DNS resolution
# Container name = hostname
# Network aliases for multiple names

docker run -d \
  --name web \
  --network app-network \
  --network-alias frontend \
  --network-alias www \
  nginx
```

## Multi-Host Networking

### Overlay Networks (Docker Swarm)

```bash
# Initialize swarm
docker swarm init

# Create overlay network
docker network create \
  --driver overlay \
  --subnet=10.0.0.0/24 \
  --attachable \
  overlay-net

# Deploy service on overlay network
docker service create \
  --name web \
  --network overlay-net \
  --replicas 3 \
  nginx
```

### Macvlan Networks

```bash
# Create macvlan network
docker network create \
  --driver macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  --opt parent=eth0 \
  macvlan-net

# Run container with macvlan
docker run -d \
  --name macvlan-container \
  --network macvlan-net \
  --ip=192.168.1.100 \
  nginx
```

## Network Security

### Network Isolation

```bash
# Create isolated networks
docker network create --internal internal-net

# No external connectivity
docker run --network internal-net alpine

# Inter-container communication only
docker run --network internal-net --name app1 nginx
docker run --network internal-net --name app2 alpine
```

### Firewall Rules

```bash
# Docker automatically creates iptables rules
# View Docker-created rules
iptables -L DOCKER
iptables -L DOCKER-USER

# Custom rules in DOCKER-USER chain
iptables -I DOCKER-USER -s 192.168.1.0/24 -j DROP
```

## Network Troubleshooting

### Debugging Tools

```bash
# Network inspection
docker network inspect bridge
docker exec <container> ip addr show
docker exec <container> ip route show

# Connectivity testing
docker exec <container> ping <target>
docker exec <container> telnet <host> <port>
docker exec <container> nslookup <hostname>

# Network utilities container
docker run --rm -it nicolaka/netshoot
```

### Common Issues

```bash
# Port already in use
netstat -tulpn | grep :8080
lsof -i :8080

# DNS resolution issues
docker exec <container> cat /etc/resolv.conf
docker exec <container> nslookup google.com

# Network connectivity
docker exec <container> traceroute <destination>
docker exec <container> ss -tulpn
```

## Network Monitoring

### Traffic Analysis

```bash
# Monitor network traffic
docker exec <container> netstat -i
docker exec <container> ss -s

# Network statistics
docker stats --format "table {{.Container}}\t{{.NetIO}}"

# Packet capture
docker exec <container> tcpdump -i eth0
```

### Network Performance

```bash
# Bandwidth testing
docker run --rm -it networkstatic/iperf3 -c <server>

# Latency testing
docker exec <container> ping -c 10 <target>

# Network throughput
docker run --rm -it appropriate/curl -w "@curl-format.txt" <url>
```

## Docker Compose Networking

### Compose Network Configuration

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    image: nginx
    networks:
      - frontend
      - backend
    ports:
      - "80:80"

  api:
    image: myapi
    networks:
      - backend
    environment:
      - DB_HOST=database

  database:
    image: postgres
    networks:
      - backend
    environment:
      - POSTGRES_PASSWORD=secret

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
```

### External Networks

```yaml
# Use existing network
networks:
  existing-network:
    external: true
    name: my-existing-network

services:
  app:
    image: myapp
    networks:
      - existing-network
```

## Production Networking

### Best Practices

```bash
# Use custom networks instead of default bridge
docker network create app-network

# Implement network segmentation
docker network create --internal backend-network
docker network create frontend-network

# Use specific IP ranges
docker network create --subnet=10.1.0.0/16 production-net

# Enable encryption for multi-host
docker network create --opt encrypted overlay-secure
```

### Load Balancing

```bash
# Use external load balancer
# HAProxy, Nginx, or cloud load balancer

# Docker Swarm built-in load balancing
docker service create \
  --name web \
  --replicas 3 \
  --publish 80:80 \
  nginx
```

## Network Examples

### Microservices Architecture

```bash
# Create networks for different tiers
docker network create frontend-tier
docker network create backend-tier
docker network create database-tier

# Web server (frontend + backend access)
docker run -d \
  --name nginx \
  --network frontend-tier \
  -p 80:80 \
  nginx

docker network connect backend-tier nginx

# API server (backend + database access)
docker run -d \
  --name api \
  --network backend-tier \
  myapi

docker network connect database-tier api

# Database (database tier only)
docker run -d \
  --name postgres \
  --network database-tier \
  postgres
```

### Development Environment

```bash
# Create development network
docker network create dev-network

# Database
docker run -d \
  --name dev-db \
  --network dev-network \
  -e POSTGRES_PASSWORD=devpass \
  postgres

# Redis cache
docker run -d \
  --name dev-redis \
  --network dev-network \
  redis

# Application
docker run -d \
  --name dev-app \
  --network dev-network \
  -p 3000:3000 \
  -e DB_HOST=dev-db \
  -e REDIS_HOST=dev-redis \
  myapp
```