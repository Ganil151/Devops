# Docker Images

Complete guide to Docker image creation, management, and optimization.

## Image Fundamentals

### What are Docker Images?

- **Read-only templates** used to create containers
- **Layered filesystem** with incremental changes
- **Immutable** - changes create new layers
- **Portable** across different environments

### Image Architecture

```
Application Layer    ← Your application code
Runtime Layer        ← Node.js, Python, etc.
OS Layer            ← Ubuntu, Alpine, etc.
Base Layer          ← Kernel interface
```

## Image Operations

### Basic Image Commands

```bash
# List images
docker images
docker image ls
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Pull images
docker pull nginx
docker pull nginx:1.21
docker pull ubuntu:20.04

# Remove images
docker rmi <image>
docker image rm <image>
docker image prune              # Remove unused images
docker image prune -a           # Remove all unused images
```

### Image Information

```bash
# Inspect image
docker inspect nginx
docker history nginx            # Show image layers
docker image inspect --format='{{.Config.Env}}' nginx
```

## Building Images

### Dockerfile Basics

```dockerfile
# Basic Dockerfile structure
FROM ubuntu:20.04
LABEL maintainer="your-email@example.com"
LABEL version="1.0"

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy files
COPY . .
COPY package.json .
ADD https://example.com/file.tar.gz /tmp/

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Expose ports
EXPOSE 3000

# Set user
USER 1000:1000

# Define volumes
VOLUME ["/data"]

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:3000/health || exit 1

# Default command
CMD ["node", "server.js"]
```

### Building Images

```bash
# Build image
docker build -t myapp .
docker build -t myapp:v1.0 .
docker build -f Dockerfile.prod -t myapp:prod .

# Build with build arguments
docker build --build-arg NODE_VERSION=16 -t myapp .

# Build with no cache
docker build --no-cache -t myapp .

# Build with specific context
docker build -t myapp /path/to/context
```

## Multi-Stage Builds

### Optimized Build Process

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
EXPOSE 3000
CMD ["node", "server.js"]
```

### Build Stages

```dockerfile
# Named stages for complex builds
FROM golang:1.19 AS build-stage
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /app

FROM alpine:latest AS runtime-stage
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=build-stage /app .
CMD ["./app"]
```

## Image Optimization

### Size Optimization

```dockerfile
# Use minimal base images
FROM alpine:3.16          # ~5MB
FROM node:16-alpine       # ~110MB vs 900MB+ for full node

# Combine RUN commands
RUN apt-get update && \
    apt-get install -y package1 package2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Use .dockerignore
# .dockerignore file
node_modules
.git
.gitignore
README.md
Dockerfile
.dockerignore
```

### Layer Optimization

```dockerfile
# Order layers by change frequency
FROM node:16-alpine

# Dependencies (changes less frequently)
COPY package*.json ./
RUN npm ci --only=production

# Application code (changes more frequently)
COPY . .

# Configuration and startup
EXPOSE 3000
CMD ["node", "server.js"]
```

## Image Security

### Security Best Practices

```dockerfile
# Use specific versions
FROM node:16.17.0-alpine3.16

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Set proper permissions
COPY --chown=nextjs:nodejs . .
USER nextjs

# Use read-only filesystem
docker run --read-only myapp

# Scan for vulnerabilities
docker scan myapp:latest
```

### Minimal Images

```dockerfile
# Distroless images
FROM gcr.io/distroless/nodejs16-debian11
COPY --from=builder /app .
EXPOSE 3000
CMD ["server.js"]

# Scratch images (for static binaries)
FROM scratch
COPY ca-certificates.crt /etc/ssl/certs/
COPY myapp /
CMD ["/myapp"]
```

## Image Registry Operations

### Docker Hub Operations

```bash
# Login to registry
docker login
docker login registry.example.com

# Tag images
docker tag myapp:latest username/myapp:latest
docker tag myapp:latest username/myapp:v1.0

# Push images
docker push username/myapp:latest
docker push username/myapp:v1.0

# Pull from private registry
docker pull registry.example.com/myapp:latest
```

### Private Registry

```bash
# Run local registry
docker run -d -p 5000:5000 --name registry registry:2

# Push to local registry
docker tag myapp localhost:5000/myapp
docker push localhost:5000/myapp

# Pull from local registry
docker pull localhost:5000/myapp
```

## Image Management

### Cleanup and Maintenance

```bash
# Remove unused images
docker image prune
docker image prune -a

# Remove images by filter
docker image prune --filter "until=24h"
docker image prune --filter "label=version=1.0"

# System cleanup
docker system prune
docker system df              # Show disk usage
```

### Image Backup and Export

```bash
# Save image to tar file
docker save myapp:latest > myapp.tar
docker save myapp:latest | gzip > myapp.tar.gz

# Load image from tar file
docker load < myapp.tar
docker load -i myapp.tar

# Export container as image
docker export <container> > container.tar
docker import container.tar myapp:exported
```

## Advanced Image Techniques

### Build Arguments and Variables

```dockerfile
# Build arguments
ARG NODE_VERSION=16
FROM node:${NODE_VERSION}-alpine

ARG BUILD_DATE
ARG VERSION
LABEL build-date=$BUILD_DATE
LABEL version=$VERSION

# Build with arguments
# docker build --build-arg NODE_VERSION=18 --build-arg VERSION=2.0 .
```

### Conditional Builds

```dockerfile
# Conditional installation
ARG ENVIRONMENT=production
RUN if [ "$ENVIRONMENT" = "development" ]; then \
      npm install; \
    else \
      npm ci --only=production; \
    fi
```

## Image Examples

### Python Application

```dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Create non-root user
RUN useradd --create-home --shell /bin/bash app
USER app

EXPOSE 8000
CMD ["python", "app.py"]
```

### Go Application

```dockerfile
# Multi-stage build for Go
FROM golang:1.19-alpine AS builder

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /src/app .
CMD ["./app"]
```