# Docker Networking

Docker networking enables containers to communicate with each other and with external networks. Understanding Docker networking is crucial for building multi-container applications.

## Network Types Overview

Docker provides several network drivers, each suited for different use cases:

```mermaid
graph TB
    subgraph "Docker Host"
        subgraph "Bridge Network default"
            C1[Container 1<br/>172.17.0.2] <--> C2[Container 2<br/>172.17.0.3]
        end
        
        subgraph "Custom Bridge Network"
            C3[Container 3] <--> C4[Container 4]
        end
        
        subgraph "Host Network"
            C5[Container 5<br/>Uses Host IP]
        end
        
        C6[Container 6<br/>None Network<br/>No Network]
    end
    
    Bridge --> Router[Host Network Interface]
    Host --> Router
    Router <--> Internet[External Network]
    
    style Bridge fill:#e3f2fd
    style Host fill:#f3e5f5
    style C6 fill:#ffcdd2
```

### Network Driver Types

| Driver | Use Case | Container Communication | External Access |
|--------|----------|------------------------|-----------------|
| **bridge** | Default, isolated containers on single host | Via container names (custom bridge) | Port mapping required |
| **host** | No network isolation, container uses host network | N/A | Direct access |
| **overlay** | Multi-host, Swarm/Kubernetes | Cross-host communication | Yes |
| **macvlan** | Legacy apps needing MAC address | Direct L2 network | Direct access |
| **none** | Complete network isolation | No communication | No access |

## Bridge Network (Default)

The **bridge** network is the default network for containers. Each container gets its own IP address in a private subnet.

### Default Bridge Network

```bash
# Run container (uses default bridge)
docker run -d --name web1 nginx

# Inspect network
docker network inspect bridge

# Container can access internet but containers must use IP
docker exec web1 ping 172.17.0.3  # Works
docker exec web1 ping web2         # Doesn't work
```

**Limitations of default bridge:**
- No automatic DNS resolution between containers
- Must use IP addresses to communicate
- All containers can see each other
- Less secure

### Custom Bridge Network (Recommended)

Custom bridge networks provide:
- ✅ Automatic DNS resolution
- ✅ Better isolation
- ✅ On-demand connectivity
- ✅ More secure

```bash
# Create custom bridge network
docker network create my-network

# Run containers on custom network
docker run -d --name web --network my-network nginx
docker run -d --name app --network my-network python:3.11

# Containers can communicate by name
docker exec app ping web  # Works!

# List networks
docker network ls

# Inspect network
docker network inspect my-network

# Remove network
docker network rm my-network
```

### Practical Example: Web App + Database

```bash
# Create network
docker network create app-network

# Run database
docker run -d \
  --name postgres-db \
  --network app-network \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=myapp \
  postgres:15

# Run application
docker run -d \
  --name web-app \
  --network app-network \
  -e DATABASE_URL=postgresql://postgres:secret@postgres-db:5432/myapp \
  -p 8080:8080 \
  my-web-app

# App can connect to database using hostname 'postgres-db'
```

## Host Network

Container shares the host's network namespace. No network isolation.

```bash
# Run with host network
docker run -d --network host nginx

# Container uses host's IP and ports directly
# No need for -p flag
curl http://localhost:80
```

**Use cases:**
- Maximum network performance needed
- Container needs to handle lots of ports
- Network configuration is complex

**Drawbacks:**
- No network isolation
- Port conflicts possible
- Less portable
- Security concerns

> [!WARNING]
> Host network mode doesn't work on Docker Desktop for Mac/Windows. It's Linux-only.

## Container Port Publishing

Expose container ports to the host or external network:

```bash
# Publish single port
docker run -d -p 8080:80 nginx
# Host:Container

# Publish to specific host interface
docker run -d -p 127.0.0.1:8080:80 nginx

# Publish all exposed ports to random ports
docker run -d -P nginx

# Multiple ports
docker run -d \
  -p 8080:80 \
  -p 8443:443 \
  nginx

# UDP port
docker run -d -p 53:53/udp dns-server

# Find published ports
docker port <container-name>
```

## Network Communication Patterns

### Pattern 1: Frontend + Backend + Database

```mermaid
graph LR
    User([User]) -->|Port 80| FE[Frontend<br/>nginx]
    FE -->|app-network| BE[Backend API<br/>node:18]
    BE -->|app-network| DB[(PostgreSQL)]
    
    subgraph "Docker Host"
        subgraph "app-network"
            FE
            BE
            DB
        end
    end
    
    style User fill:#e3f2fd
    style FE fill:#f3e5f5
    style BE fill:#fff3e0
    style DB fill:#e8f5e9
```

```bash
# Create network
docker network create app-network

# Database (no exposed ports)
docker run -d \
  --name db \
  --network app-network \
  postgres:15

# Backend (no exposed ports)
docker run -d \
  --name backend \
  --network app-network \
  -e DB_HOST=db \
  my-backend-api

# Frontend (public port)
docker run -d \
  --name frontend \
  --network app-network \
  -p 80:80 \
  -e API_URL=http://backend:3000 \
  my-frontend
```

### Pattern 2: Multiple Networks

Containers can connect to multiple networks:

```bash
# Create networks
docker network create frontend-network
docker network create backend-network

# Database on backend network only
docker run -d \
  --name db \
  --network backend-network \
  postgres:15

# API on both networks
docker run -d \
  --name api \
  --network backend-network \
  my-api

docker network connect frontend-network api

# Frontend on frontend network only
docker run -d \
  --name web \
  --network frontend-network \
  -p 80:80 \
  nginx
```

```mermaid
graph TB
    subgraph "frontend-network"
        WEB[Web Frontend]
        API1[API Server]
    end
    
    subgraph "backend-network"
        API2[API Server]
        DB[(Database)]
    end
    
    API1 -.Same Container.- API2
    
    WEB --> API1
    API2 --> DB
    
    style WEB fill:#e3f2fd
    style API1 fill:#fff3e0
    style API2 fill:#fff3e0
    style DB fill:#e8f5e9
```

## Managing Networks

### Create Networks

```bash
# Basic network
docker network create my-network

# With subnet
docker network create \
  --subnet=172.20.0.0/16 \
  my-network

# With gateway
docker network create \
  --subnet=172.20.0.0/16 \
  --gateway=172.20.0.1 \
  my-network

# With IP range for containers
docker network create \
  --subnet=172.20.0.0/16 \
  --ip-range=172.20.240.0/20 \
  my-network

# With driver options
docker network create \
  --driver=bridge \
  --opt com.docker.network.bridge.name=br-custom \
  my-network
```

### Connect/Disconnect Containers

```bash
# Connect container to network
docker network connect my-network container1

# Connect with specific IP
docker network connect --ip 172.20.0.10 my-network container1

# Connect with alias
docker network connect --alias api my-network container1

# Disconnect
docker network disconnect my-network container1
```

### Inspect and List

```bash
# List networks
docker network ls

# Filter networks
docker network ls --filter driver=bridge

# Inspect network
docker network inspect my-network

# Show containers in network
docker network inspect -f '{{range .Containers}}{{.Name}} {{end}}' my-network
```

### Remove Networks

```bash
# Remove network
docker network rm my-network

# Remove all unused networks
docker network prune

# Remove specific networks
docker network rm network1 network2 network3
```

## DNS and Service Discovery

In custom bridge networks, Docker provides automatic DNS resolution:

```bash
# Create network
docker network create app-net

# Run containers
docker run -d --name db --network app-net postgres
docker run -d --name cache --network app-net redis
docker run -d --name api --network app-net my-api

# Containers can resolve each other by name
docker exec api ping db     # Works!
docker exec api ping cache  # Works!
```

### DNS Round Robin (Multiple Containers, Same Alias)

```bash
# Create network
docker network create loadbalanced

# Run 3 web servers with same alias
docker run -d --network loadbalanced --network-alias web nginx
docker run -d --network loadbalanced --network-alias web nginx
docker run -d --network loadbalanced --network-alias web nginx

# Client resolves 'web' to all 3 IPs (round-robin)
docker run --network loadbalanced alpine nslookup web
```

## Network Security

### Isolate with Multiple Networks

```bash
# Public network (exposed services)
docker network create public

# Private network (internal services)
docker network create private

# Frontend in public
docker run -d --name frontend --network public -p 80:80 nginx

# Backend in both networks
docker run -d --name backend my-api
docker network connect public backend
docker network connect private backend

# Database in private only
docker run -d --name db --network private postgres
```

### Restrict Container Communication

```bash
# Create isolated network
docker network create \
  --internal \
  secure-network

# Containers can't reach external internet
docker run -d \
  --name isolated-app \
  --network secure-network \
  my-app

# Can communicate internally but not externally
```

## Overlay Networks (Swarm/Multi-Host)

Overlay networks enable multi-host communication in Docker Swarm:

```bash
# Initialize swarm
docker swarm init

# Create overlay network
docker network create \
  --driver overlay \
  --attachable \
  my-overlay

# Deploy services
docker service create \
  --name web \
  --network my-overlay \
  --replicas 3 \
  nginx
```

> [!NOTE]
> Overlay networks are primarily used in Docker Swarm or Kubernetes environments for multi-host container communication.

## Macvlan Network

Assign MAC address to containers, making them appear as physical devices:

```bash
# Create macvlan network
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  macvlan-net

# Run container with macvlan
docker run -d \
  --network macvlan-net \
  --ip=192.168.1.100 \
  nginx
```

**Use cases:**
- Legacy applications requiring MAC addresses
- Network monitoring applications
- Applications that need direct Layer 2 access

## Troubleshooting

### Check Container Network Settings

```bash
# Inspect container network
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container-name

# Show all network details
docker inspect container-name

# View container interfaces
docker exec container-name ip addr show

# Check routing
docker exec container-name ip route
```

### Test Connectivity

```bash
# Ping between containers
docker exec container1 ping container2

# DNS resolution
docker exec container1 nslookup container2

# Check port connectivity
docker exec container1 nc -zv container2 80

# Trace route
docker exec container1 traceroute container2
```

### Common Issues

#### Containers Can't Communicate

```bash
# Check if on same network
docker network inspect my-network

# Verify DNS resolution
docker exec container1 ping container2

# Check firewall rules
sudo iptables -L
```

#### Port Already in Use

```bash
# Find process using port
sudo lsof -i :8080
sudo netstat -tulpn | grep 8080

# Use different host port
docker run -d -p 8081:80 nginx
```

#### Network Performance Issues

```bash
# Check stats
docker stats

# Use host network for better performance
docker run --network host my-app

# Check MTU settings
docker network inspect bridge -f '{{.Options}}'
```

## Best Practices

1. **Use Custom Bridge Networks**: Better isolation and DNS resolution
2. **One Network Per Application Stack**: Group related containers
3. **Don't Expose Unnecessary Ports**: Only publish what's needed
4. **Use Network Aliases**: For load balancing and flexibility
5. **Name Your Networks**: Descriptive names for clarity
6. **Clean Up Unused Networks**: Regular pruning
7. **Document Network Architecture**: Clear diagrams and documentation
8. **Use Internal Networks**: For databases and internal services

## Network Commands Cheat Sheet

```bash
# Network Management
docker network create <name>              # Create network
docker network ls                         # List networks
docker network inspect <name>             # Inspect network
docker network rm <name>                  # Remove network
docker network prune                      # Remove unused networks

# Container Network Operations
docker network connect <net> <container>  # Connect container
docker network disconnect <net> <container> # Disconnect container
docker run --network <name> <image>       # Run on network
docker run -p 8080:80 <image>            # Publish port

# Inspection
docker port <container>                   # Show port mappings
docker inspect <container>                # Full container details
docker exec <container> ip addr           # Container IP
```

## Next Steps

- Continue to [Docker Volumes](../02-Docker-Volumes/README.md)
- Learn about [Multi-Stage Builds](../03-Multi-Stage-Builds/README.md)
- Explore [Docker Compose for Multi-Container Apps](../../Docker-Compose/Beginner/01-Basics/README.md)

## Resources

- [Docker Networking Documentation](https://docs.docker.com/network/)
- [Network Drivers](https://docs.docker.com/network/drivers/)
- [Overlay Networks](https://docs.docker.com/network/overlay/)
- [Container Networking Tutorial](https://docs.docker.com/config/containers/container-networking/)

---

**[← Previous: Dockerfile Basics](../../Beginner/03-Dockerfile-Basics/README.md)** | **[Next: Docker Volumes →](../02-Docker-Volumes/README.md)**
