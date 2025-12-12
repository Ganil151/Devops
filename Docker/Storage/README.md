# Docker Storage

Complete guide to Docker volumes, bind mounts, and data persistence strategies.

## Storage Fundamentals

### Docker Storage Types

- **Volumes**: Managed by Docker, stored in Docker area
- **Bind Mounts**: Direct host filesystem mapping
- **tmpfs Mounts**: Temporary filesystem in memory
- **Named Pipes**: Windows-specific (not covered here)

### Storage Architecture

```
Container Layer (R/W)     ← Application writes
Image Layers (R/O)        ← Base image files
Volume/Bind Mount         ← Persistent data
Host Filesystem           ← Actual storage
```

## Docker Volumes

### Volume Management

```bash
# List volumes
docker volume ls
docker volume ls --format "table {{.Name}}\t{{.Driver}}\t{{.Mountpoint}}"

# Create volume
docker volume create myvolume
docker volume create --driver local myvolume
docker volume create --opt type=nfs --opt device=:/path myvolume

# Inspect volume
docker volume inspect myvolume

# Remove volume
docker volume rm myvolume
docker volume prune              # Remove unused volumes
```

### Using Volumes

```bash
# Mount volume to container
docker run -v myvolume:/data nginx
docker run --mount source=myvolume,target=/data nginx

# Anonymous volume
docker run -v /data nginx

# Multiple volumes
docker run -v vol1:/data1 -v vol2:/data2 nginx
```

### Volume Drivers

```bash
# Local driver (default)
docker volume create --driver local myvolume

# NFS volume
docker volume create \
  --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.100,rw \
  --opt device=:/path/to/dir \
  nfs-volume

# CIFS/SMB volume
docker volume create \
  --driver local \
  --opt type=cifs \
  --opt o=username=user,password=pass \
  --opt device=//server/share \
  smb-volume
```

## Bind Mounts

### Basic Bind Mounts

```bash
# Bind mount host directory
docker run -v /host/path:/container/path nginx
docker run --mount type=bind,source=/host/path,target=/container/path nginx

# Read-only bind mount
docker run -v /host/path:/container/path:ro nginx
docker run --mount type=bind,source=/host/path,target=/container/path,readonly nginx

# Bind mount with specific options
docker run --mount type=bind,source=/host/path,target=/container/path,bind-propagation=shared nginx
```

### Bind Mount Use Cases

```bash
# Development - source code mounting
docker run -v $(pwd):/app -w /app node:16 npm start

# Configuration files
docker run -v /etc/nginx/nginx.conf:/etc/nginx/nginx.conf:ro nginx

# Log files
docker run -v /var/log/app:/var/log/app myapp

# Shared data between containers
docker run -v /shared:/data container1
docker run -v /shared:/data container2
```

## tmpfs Mounts

### Memory-Based Storage

```bash
# Create tmpfs mount
docker run --tmpfs /tmp nginx
docker run --mount type=tmpfs,destination=/tmp nginx

# tmpfs with size limit
docker run --tmpfs /tmp:size=100m nginx
docker run --mount type=tmpfs,destination=/tmp,tmpfs-size=100m nginx

# tmpfs with specific options
docker run --mount type=tmpfs,destination=/tmp,tmpfs-mode=1777 nginx
```

### tmpfs Use Cases

```bash
# Temporary processing data
docker run --tmpfs /tmp:size=1g,noexec processing-app

# Security - sensitive data in memory
docker run --tmpfs /secrets:noexec,nosuid,size=100m secure-app

# Performance - fast temporary storage
docker run --tmpfs /cache:size=500m cache-app
```

## Data Persistence Strategies

### Database Persistence

```bash
# PostgreSQL with volume
docker run -d \
  --name postgres \
  -v postgres-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=secret \
  postgres:13

# MySQL with volume
docker run -d \
  --name mysql \
  -v mysql-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=secret \
  mysql:8.0

# MongoDB with volume
docker run -d \
  --name mongo \
  -v mongo-data:/data/db \
  mongo:5.0
```

### Application Data

```bash
# Web application uploads
docker run -d \
  --name webapp \
  -v app-uploads:/app/uploads \
  -v app-logs:/app/logs \
  mywebapp

# Configuration persistence
docker run -d \
  --name app \
  -v app-config:/etc/myapp \
  -v /host/config:/etc/myapp:ro \
  myapp
```

## Volume Backup and Restore

### Backup Strategies

```bash
# Backup volume to tar file
docker run --rm \
  -v myvolume:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/backup.tar.gz -C /data .

# Backup with timestamp
docker run --rm \
  -v myvolume:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/backup-$(date +%Y%m%d-%H%M%S).tar.gz -C /data .

# Database backup
docker exec postgres pg_dump -U postgres mydb > backup.sql
```

### Restore Operations

```bash
# Restore volume from tar file
docker run --rm \
  -v myvolume:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/backup.tar.gz -C /data

# Database restore
docker exec -i postgres psql -U postgres mydb < backup.sql

# Copy data between volumes
docker run --rm \
  -v source-volume:/source \
  -v target-volume:/target \
  alpine cp -a /source/. /target/
```

## Storage Performance

### Performance Optimization

```bash
# Use volumes for better performance than bind mounts
docker run -v myvolume:/data myapp

# SSD storage for databases
docker volume create --driver local \
  --opt type=none \
  --opt o=bind \
  --opt device=/ssd/path \
  ssd-volume

# Memory-based storage for temporary data
docker run --tmpfs /tmp:size=1g myapp
```

### Storage Monitoring

```bash
# Check volume usage
docker system df
docker system df -v

# Container storage usage
docker exec <container> df -h
docker exec <container> du -sh /data

# Host storage impact
du -sh /var/lib/docker/volumes/
```

## Advanced Storage Configurations

### Multi-Mount Scenarios

```bash
# Multiple storage types
docker run -d \
  --name complex-app \
  -v app-data:/app/data \                    # Volume for data
  -v /host/config:/app/config:ro \           # Bind mount for config
  --tmpfs /app/temp:size=100m \              # tmpfs for temp files
  -v app-logs:/var/log/app \                 # Volume for logs
  myapp
```

### Storage with Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    image: nginx
    volumes:
      - web-content:/usr/share/nginx/html
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - web-logs:/var/log/nginx

  app:
    image: myapp
    volumes:
      - app-data:/app/data
      - ./config:/app/config:ro
    tmpfs:
      - /tmp:size=100m

  db:
    image: postgres
    volumes:
      - db-data:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=secret

volumes:
  web-content:
  web-logs:
  app-data:
  db-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /ssd/postgres-data
```

## Storage Security

### Secure Storage Practices

```bash
# Read-only mounts for security
docker run -v /etc/ssl:/etc/ssl:ro nginx

# Specific user ownership
docker run --user 1000:1000 -v myvolume:/data myapp

# SELinux labels (on SELinux systems)
docker run -v /host/path:/container/path:Z myapp

# AppArmor profiles
docker run --security-opt apparmor:my-profile -v myvolume:/data myapp
```

### Encryption

```bash
# Encrypted volumes (using LUKS)
# Create encrypted device first, then mount as volume

# Network storage with encryption
docker volume create \
  --driver local \
  --opt type=nfs \
  --opt o=addr=server,rw,nfsvers=4,proto=tcp,sec=krb5p \
  --opt device=:/encrypted/path \
  encrypted-nfs
```

## Troubleshooting Storage

### Common Issues

```bash
# Permission issues
docker exec <container> ls -la /data
docker exec <container> id
chown -R 1000:1000 /host/path

# Space issues
docker system df
docker volume ls --filter dangling=true
docker system prune --volumes

# Mount issues
docker inspect <container> | grep -A 10 Mounts
mount | grep docker
```

### Debugging Commands

```bash
# Check volume details
docker volume inspect myvolume
docker inspect <container> | jq '.[0].Mounts'

# Storage driver information
docker info | grep -A 10 "Storage Driver"

# Container filesystem layers
docker history <image>
docker diff <container>
```

## Production Storage

### Best Practices

```bash
# Use named volumes for important data
docker volume create --name production-db-data

# Implement backup strategies
# Regular automated backups
# Test restore procedures
# Monitor storage usage

# Use appropriate storage drivers
# Local for single-host
# Network storage for multi-host
# Cloud storage for scalability
```

### High Availability

```bash
# Shared storage for multiple hosts
docker volume create \
  --driver local \
  --opt type=nfs \
  --opt o=addr=nfs-server,rw \
  --opt device=:/shared/data \
  shared-volume

# Replicated storage
# Use storage solutions like:
# - GlusterFS
# - Ceph
# - Cloud provider storage (EBS, etc.)
```

## Storage Examples

### Development Environment

```bash
# Development setup with live reload
docker run -d \
  --name dev-app \
  -v $(pwd)/src:/app/src \
  -v $(pwd)/config:/app/config:ro \
  -v node-modules:/app/node_modules \
  -p 3000:3000 \
  node:16

# Database for development
docker run -d \
  --name dev-db \
  -v dev-db-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=devpass \
  postgres:13
```

### Production Deployment

```bash
# Production web application
docker run -d \
  --name prod-web \
  --restart unless-stopped \
  -v web-content:/var/www/html \
  -v web-logs:/var/log/nginx \
  -v /etc/ssl:/etc/ssl:ro \
  nginx:alpine

# Production database with backup
docker run -d \
  --name prod-db \
  --restart unless-stopped \
  -v prod-db-data:/var/lib/postgresql/data \
  -v prod-db-backup:/backup \
  postgres:13
```