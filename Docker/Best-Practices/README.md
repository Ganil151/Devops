# Docker Best Practices

Production-ready Docker deployment patterns and optimization strategies.

## Development Best Practices

### Dockerfile Optimization

```dockerfile
# Use multi-stage builds
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

# Layer optimization - order by change frequency
# 1. Base image (changes rarely)
# 2. System dependencies (changes rarely)
# 3. Application dependencies (changes occasionally)
# 4. Application code (changes frequently)
```

### Image Size Optimization

```dockerfile
# Use minimal base images
FROM alpine:3.16              # ~5MB
FROM node:16-alpine          # ~110MB vs 900MB+ full image

# Combine RUN commands
RUN apt-get update && \
    apt-get install -y package1 package2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Use .dockerignore
node_modules
.git
*.md
.env
Dockerfile
```

### Security Best Practices

```dockerfile
# Run as non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001
USER nextjs

# Use specific versions
FROM node:16.17.0-alpine3.16

# Scan for vulnerabilities
RUN npm audit --audit-level high
```

## Production Deployment

### Container Configuration

```bash
# Production container settings
docker run -d \
  --name production-app \
  --restart unless-stopped \
  --memory=1g \
  --cpus="2" \
  --read-only \
  --tmpfs /tmp:noexec,nosuid,size=100m \
  --user 1000:1000 \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  -p 80:3000 \
  myapp:v1.0
```

### Health Checks

```dockerfile
# Application health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Database health check
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD pg_isready -U postgres || exit 1
```

### Resource Management

```bash
# Set appropriate limits
docker run -d \
  --memory=512m \
  --memory-swap=1g \
  --cpus="1.5" \
  --pids-limit=100 \
  myapp

# Monitor resource usage
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
```

## Logging and Monitoring

### Centralized Logging

```bash
# Configure logging driver
docker run -d \
  --log-driver=fluentd \
  --log-opt fluentd-address=localhost:24224 \
  --log-opt tag="myapp.{{.Name}}" \
  myapp

# JSON logging format
docker run -d \
  --log-driver=json-file \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  myapp
```

### Application Monitoring

```yaml
# docker-compose.yml with monitoring
version: '3.8'
services:
  app:
    image: myapp:latest
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1'
        reservations:
          memory: 256M
          cpus: '0.5'
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## Performance Optimization

### Build Performance

```dockerfile
# Optimize build context
# Use .dockerignore to exclude unnecessary files

# Cache dependencies separately
COPY package*.json ./
RUN npm ci --only=production

# Copy application code last
COPY . .

# Use BuildKit for parallel builds
# DOCKER_BUILDKIT=1 docker build .
```

### Runtime Performance

```bash
# Use appropriate base images
FROM node:16-alpine    # For Node.js apps
FROM python:3.9-slim   # For Python apps
FROM openjdk:11-jre    # For Java apps

# Optimize JVM settings for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Use init system for proper signal handling
docker run --init myapp
```

### Network Performance

```bash
# Use host networking for high-performance apps
docker run --network host myapp

# Optimize network settings
docker run --sysctl net.core.somaxconn=1024 myapp

# Use custom networks for better isolation
docker network create --driver bridge app-network
```

## Data Management

### Volume Best Practices

```bash
# Use named volumes for important data
docker volume create app-data
docker run -v app-data:/data myapp

# Backup strategies
docker run --rm \
  -v app-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/backup.tar.gz -C /data .

# Use bind mounts for development
docker run -v $(pwd):/app myapp
```

### Database Containers

```bash
# PostgreSQL production setup
docker run -d \
  --name postgres \
  --restart always \
  -e POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password \
  -v postgres-data:/var/lib/postgresql/data \
  -v /etc/postgresql/postgresql.conf:/etc/postgresql/postgresql.conf:ro \
  --memory=2g \
  --cpus="2" \
  postgres:13

# MySQL production setup
docker run -d \
  --name mysql \
  --restart always \
  -e MYSQL_ROOT_PASSWORD_FILE=/run/secrets/mysql_root_password \
  -v mysql-data:/var/lib/mysql \
  -v /etc/mysql/my.cnf:/etc/mysql/my.cnf:ro \
  --memory=2g \
  mysql:8.0
```

## CI/CD Integration

### Build Pipeline

```yaml
# .github/workflows/docker.yml
name: Docker Build and Push
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1
        
      - name: Login to DockerHub
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
          
      - name: Build and push
        uses: docker/build-push-action@v2
        with:
          context: .
          push: true
          tags: myapp:latest,myapp:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Deployment Strategies

```bash
# Blue-Green Deployment
# Deploy new version
docker run -d --name app-green myapp:v2.0

# Health check
curl -f http://app-green:3000/health

# Switch traffic
docker stop app-blue
docker rm app-blue
docker rename app-green app-blue

# Rolling Updates with Docker Swarm
docker service update --image myapp:v2.0 myapp-service
```

## Security Hardening

### Runtime Security

```bash
# Security-hardened container
docker run -d \
  --name secure-app \
  --read-only \
  --tmpfs /tmp:noexec,nosuid,size=100m \
  --user 1000:1000 \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --security-opt no-new-privileges \
  --security-opt apparmor:docker-default \
  myapp:latest
```

### Image Security

```dockerfile
# Security-focused Dockerfile
FROM node:16-alpine

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Install security updates
RUN apk update && apk upgrade

# Set working directory
WORKDIR /app

# Copy and install dependencies
COPY --chown=nextjs:nodejs package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copy application
COPY --chown=nextjs:nodejs . .

# Switch to non-root user
USER nextjs

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD node healthcheck.js || exit 1

EXPOSE 3000
CMD ["node", "server.js"]
```

## Troubleshooting

### Common Issues

```bash
# Container won't start
docker logs <container>
docker inspect <container>
docker events --filter container=<container>

# Performance issues
docker stats <container>
docker exec <container> top
docker exec <container> free -h

# Network connectivity
docker exec <container> ping <target>
docker exec <container> netstat -tulpn
docker network inspect <network>

# Storage issues
docker exec <container> df -h
docker system df
docker volume inspect <volume>
```

### Debugging Tools

```bash
# Debug container with tools
docker run -it --rm \
  --pid container:<target> \
  --net container:<target> \
  --cap-add SYS_PTRACE \
  nicolaka/netshoot

# Inspect running processes
docker exec <container> ps aux
docker top <container>

# File system analysis
docker diff <container>
docker exec <container> find / -name "*.log" -type f
```

## Maintenance

### Regular Maintenance Tasks

```bash
# Clean up unused resources
docker system prune -a --volumes

# Update base images
docker pull alpine:latest
docker pull node:16-alpine

# Backup important data
docker run --rm \
  -v important-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/backup-$(date +%Y%m%d).tar.gz -C /data .

# Monitor disk usage
docker system df
du -sh /var/lib/docker/
```

### Automated Maintenance

```bash
#!/bin/bash
# maintenance.sh - Run weekly

# Clean up old containers
docker container prune -f --filter "until=168h"

# Clean up old images
docker image prune -f --filter "until=168h"

# Clean up old volumes
docker volume prune -f

# Clean up old networks
docker network prune -f

# Update running containers (if using watchtower)
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower --run-once
```

## Production Checklist

### Pre-Deployment

```bash
☐ Security scan completed
☐ Performance testing done
☐ Health checks implemented
☐ Logging configured
☐ Monitoring setup
☐ Backup strategy in place
☐ Resource limits set
☐ Non-root user configured
☐ Secrets management implemented
☐ Network security configured
```

### Post-Deployment

```bash
☐ Application responding correctly
☐ Health checks passing
☐ Logs being collected
☐ Metrics being reported
☐ Alerts configured
☐ Backup verification
☐ Performance monitoring active
☐ Security monitoring enabled
☐ Documentation updated
☐ Team notified
```

## Environment-Specific Configurations

### Development

```yaml
# docker-compose.dev.yml
version: '3.8'
services:
  app:
    build: .
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    ports:
      - "3000:3000"
```

### Staging

```yaml
# docker-compose.staging.yml
version: '3.8'
services:
  app:
    image: myapp:${VERSION}
    environment:
      - NODE_ENV=staging
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1'
```

### Production

```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  app:
    image: myapp:${VERSION}
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 1G
          cpus: '2'
        reservations:
          memory: 512M
          cpus: '1'
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```