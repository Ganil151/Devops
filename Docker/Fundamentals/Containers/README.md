# Docker Containers

Complete guide to Docker container lifecycle management and operations.

## Container Lifecycle

```
Create → Start → Run → Stop → Remove
   ↓       ↓      ↓      ↓       ↓
Built → Running → Active → Stopped → Deleted
```

## Basic Container Operations

### Creating and Running Containers

```bash
# Run container from image
docker run nginx
docker run -d nginx                    # Detached mode
docker run -it ubuntu bash            # Interactive mode
docker run --name web nginx           # Named container
docker run -p 8080:80 nginx          # Port mapping
docker run -v /host:/container nginx   # Volume mounting
```

### Container Management

```bash
# List containers
docker ps                    # Running containers
docker ps -a                # All containers
docker ps -q                # Container IDs only

# Start/Stop containers
docker start <container>     # Start stopped container
docker stop <container>      # Graceful stop
docker kill <container>      # Force stop
docker restart <container>   # Restart container

# Remove containers
docker rm <container>        # Remove stopped container
docker rm -f <container>     # Force remove running container
docker container prune      # Remove all stopped containers
```

## Container Inspection

### Getting Container Information

```bash
# Inspect container
docker inspect <container>
docker logs <container>
docker stats <container>
docker top <container>

# Execute commands in running container
docker exec -it <container> bash
docker exec <container> ls /app
```

### Container Resource Usage

```bash
# Monitor resource usage
docker stats
docker stats --no-stream
docker system df
docker system events
```

## Advanced Container Operations

### Environment Variables

```bash
# Set environment variables
docker run -e NODE_ENV=production node
docker run --env-file .env node
```

### Working Directory and User

```bash
# Set working directory and user
docker run -w /app node
docker run -u 1000:1000 node
docker run --user $(id -u):$(id -g) node
```

### Container Networking

```bash
# Network modes
docker run --network bridge nginx     # Default
docker run --network host nginx       # Host networking
docker run --network none nginx       # No networking
docker run --network custom-net nginx # Custom network
```

## Container Best Practices

### Resource Limits

```bash
# Memory and CPU limits
docker run -m 512m nginx              # Memory limit
docker run --cpus="1.5" nginx         # CPU limit
docker run --memory=1g --cpus="2" nginx
```

### Health Checks

```bash
# Built-in health check
docker run --health-cmd="curl -f http://localhost/" nginx
docker run --health-interval=30s --health-timeout=3s nginx
```

### Container Security

```bash
# Security options
docker run --read-only nginx          # Read-only filesystem
docker run --no-new-privileges nginx  # Prevent privilege escalation
docker run --cap-drop ALL nginx       # Drop all capabilities
```

## Troubleshooting Containers

### Common Issues

```bash
# Debug container issues
docker logs <container>               # Check logs
docker exec -it <container> sh       # Access container shell
docker inspect <container>           # Detailed information
docker events                        # Real-time events
```

### Container States

- **Created**: Container created but not started
- **Running**: Container is running
- **Paused**: Container processes are paused
- **Restarting**: Container is restarting
- **Exited**: Container has stopped
- **Dead**: Container is in dead state

## Container Cleanup

### Cleanup Commands

```bash
# Remove stopped containers
docker container prune

# Remove all containers
docker rm $(docker ps -aq)

# Remove containers older than 24h
docker container prune --filter "until=24h"

# System-wide cleanup
docker system prune
docker system prune -a              # Include unused images
```

## Production Considerations

### Container Monitoring

```bash
# Resource monitoring
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Log management
docker logs --tail 100 <container>
docker logs --since 2h <container>
docker logs -f <container>          # Follow logs
```

### Container Orchestration

- Use Docker Compose for multi-container applications
- Consider Kubernetes for production orchestration
- Implement proper health checks and restart policies
- Use init systems for proper signal handling

## Examples

### Web Application Container

```bash
# Run web application with proper configuration
docker run -d \
  --name webapp \
  --restart unless-stopped \
  -p 80:3000 \
  -e NODE_ENV=production \
  -v /app/logs:/var/log/app \
  --memory=512m \
  --cpus="1" \
  myapp:latest
```

### Database Container

```bash
# Run database with persistent storage
docker run -d \
  --name postgres-db \
  --restart always \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=secretpassword \
  -v postgres-data:/var/lib/postgresql/data \
  --memory=1g \
  postgres:13
```