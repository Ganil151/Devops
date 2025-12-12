# Docker Compose Guide

Complete guide for managing multi-container applications with Docker Compose.

## What is Docker Compose?

Docker Compose is a tool for defining and running multi-container Docker applications using a YAML file to configure services, networks, and volumes.

### Key Benefits
- **Multi-container orchestration**: Manage related containers together
- **Declarative configuration**: Define infrastructure as code
- **Environment management**: Different configurations for dev/staging/prod
- **Service discovery**: Automatic networking between containers
- **Simplified deployment**: Single command to start entire application stack

## Installation

### Linux
```bash
# Download Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version
```

### Alternative Installation
```bash
# Install via pip
pip install docker-compose

# Install via package manager (Ubuntu)
sudo apt install docker-compose
```

## Basic Compose File Structure

### docker-compose.yml
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8080:80"
    depends_on:
      - db
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=mydb
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

## Service Configuration

### Build Configuration
```yaml
services:
  web:
    # Build from Dockerfile in current directory
    build: .
    
    # Build with custom context and Dockerfile
    build:
      context: ./web
      dockerfile: Dockerfile.dev
      args:
        - NODE_ENV=development
      target: development
    
    # Use pre-built image
    image: nginx:alpine
```

### Port Mapping
```yaml
services:
  web:
    ports:
      - "8080:80"              # Host:Container
      - "443:443"
      - "127.0.0.1:8081:81"    # Bind to specific interface
    
    # Expose ports without publishing to host
    expose:
      - "3000"
      - "8000"
```

### Environment Variables
```yaml
services:
  web:
    environment:
      - NODE_ENV=production
      - DEBUG=false
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
    
    # Or use array format
    environment:
      NODE_ENV: production
      DEBUG: "false"
    
    # Load from file
    env_file:
      - .env
      - .env.local
```

### Volume Mounting
```yaml
services:
  web:
    volumes:
      # Named volume
      - app_data:/app/data
      
      # Bind mount
      - ./src:/app/src
      - /host/path:/container/path
      
      # Read-only mount
      - ./config:/app/config:ro
      
      # Temporary filesystem
      - type: tmpfs
        target: /tmp
        tmpfs:
          size: 100M

volumes:
  app_data:
```

## Advanced Service Configuration

### Resource Limits
```yaml
services:
  web:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    
    # Alternative syntax (Docker Compose v2.4+)
    mem_limit: 512m
    cpus: 0.5
```

### Health Checks
```yaml
services:
  web:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    
    # Disable health check
    # healthcheck:
    #   disable: true
```

### Restart Policies
```yaml
services:
  web:
    restart: unless-stopped
    # Options: no, always, on-failure, unless-stopped
    
  db:
    restart: on-failure:3  # Restart max 3 times on failure
```

### Dependencies
```yaml
services:
  web:
    depends_on:
      - db
      - redis
    
    # With condition (requires healthcheck)
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
```

## Networking

### Default Network
```yaml
# All services automatically join default network
services:
  web:
    image: nginx
  api:
    image: node:alpine
# web can reach api at hostname 'api'
```

### Custom Networks
```yaml
services:
  web:
    networks:
      - frontend
      - backend
  
  api:
    networks:
      - backend
  
  db:
    networks:
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access
```

### Network Configuration
```yaml
networks:
  custom:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
          ip_range: 172.20.240.0/20
          gateway: 172.20.0.1
    driver_opts:
      com.docker.network.bridge.name: custom_bridge
```

## Volume Management

### Named Volumes
```yaml
services:
  db:
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /host/path/to/data
```

### External Volumes
```yaml
volumes:
  postgres_data:
    external: true
    name: my_existing_volume
```

## Environment-Specific Configurations

### Multiple Compose Files
```bash
# Base configuration
# docker-compose.yml

# Development overrides
# docker-compose.override.yml (loaded automatically)

# Production overrides
# docker-compose.prod.yml

# Use specific files
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

### docker-compose.override.yml
```yaml
version: '3.8'

services:
  web:
    build:
      target: development
    volumes:
      - ./src:/app/src
    environment:
      - NODE_ENV=development
      - DEBUG=true
    command: npm run dev
```

### docker-compose.prod.yml
```yaml
version: '3.8'

services:
  web:
    build:
      target: production
    restart: unless-stopped
    environment:
      - NODE_ENV=production
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 512M
```

## Essential Commands

### Basic Operations
```bash
# Start services
docker-compose up
docker-compose up -d                    # Detached mode
docker-compose up --build               # Rebuild images
docker-compose up --force-recreate      # Force recreate containers

# Stop services
docker-compose stop
docker-compose down                     # Stop and remove containers
docker-compose down -v                  # Also remove volumes
docker-compose down --rmi all           # Also remove images

# View status
docker-compose ps
docker-compose ps -a                    # Include stopped containers
```

### Service Management
```bash
# Start specific service
docker-compose up web
docker-compose start web

# Stop specific service
docker-compose stop web

# Restart services
docker-compose restart
docker-compose restart web

# Scale services
docker-compose up -d --scale web=3
```

### Logs and Debugging
```bash
# View logs
docker-compose logs
docker-compose logs web                 # Specific service
docker-compose logs -f                  # Follow logs
docker-compose logs --tail=100          # Last 100 lines

# Execute commands
docker-compose exec web bash
docker-compose exec web ls /app
docker-compose run web npm test         # Run one-off command
```

### Build and Images
```bash
# Build images
docker-compose build
docker-compose build --no-cache web     # Build without cache

# Pull images
docker-compose pull

# Push images (if configured)
docker-compose push
```

## Real-World Examples

### LAMP Stack
```yaml
version: '3.8'

services:
  web:
    image: php:8.1-apache
    ports:
      - "80:80"
    volumes:
      - ./src:/var/www/html
    depends_on:
      - db

  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: myapp
      MYSQL_USER: user
      MYSQL_PASSWORD: userpass
    volumes:
      - mysql_data:/var/lib/mysql
    ports:
      - "3306:3306"

  phpmyadmin:
    image: phpmyadmin:latest
    ports:
      - "8080:80"
    environment:
      PMA_HOST: db
      PMA_USER: root
      PMA_PASSWORD: rootpass
    depends_on:
      - db

volumes:
  mysql_data:
```

### Node.js + MongoDB + Redis
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - MONGODB_URI=mongodb://mongo:27017/myapp
      - REDIS_URL=redis://redis:6379
    depends_on:
      - mongo
      - redis
    restart: unless-stopped

  mongo:
    image: mongo:5
    volumes:
      - mongo_data:/data/db
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - app
    restart: unless-stopped

volumes:
  mongo_data:
  redis_data:
```

### Microservices Architecture
```yaml
version: '3.8'

services:
  # API Gateway
  gateway:
    build: ./gateway
    ports:
      - "80:8080"
    environment:
      - USER_SERVICE_URL=http://user-service:3000
      - ORDER_SERVICE_URL=http://order-service:3000
    depends_on:
      - user-service
      - order-service
    networks:
      - frontend
      - backend

  # User Service
  user-service:
    build: ./user-service
    environment:
      - DATABASE_URL=postgresql://user:pass@user-db:5432/users
    depends_on:
      - user-db
    networks:
      - backend

  user-db:
    image: postgres:13
    environment:
      POSTGRES_DB: users
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - user_data:/var/lib/postgresql/data
    networks:
      - backend

  # Order Service
  order-service:
    build: ./order-service
    environment:
      - DATABASE_URL=postgresql://user:pass@order-db:5432/orders
    depends_on:
      - order-db
    networks:
      - backend

  order-db:
    image: postgres:13
    environment:
      POSTGRES_DB: orders
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - order_data:/var/lib/postgresql/data
    networks:
      - backend

  # Shared Services
  redis:
    image: redis:7-alpine
    networks:
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true

volumes:
  user_data:
  order_data:
```

## Best Practices

### File Organization
```
project/
├── docker-compose.yml           # Base configuration
├── docker-compose.override.yml  # Development overrides
├── docker-compose.prod.yml      # Production configuration
├── .env                         # Environment variables
├── .env.example                 # Environment template
└── services/
    ├── web/
    │   ├── Dockerfile
    │   └── src/
    └── api/
        ├── Dockerfile
        └── src/
```

### Environment Variables
```bash
# .env file
COMPOSE_PROJECT_NAME=myapp
POSTGRES_PASSWORD=secure_password
NODE_ENV=development
```

### Security Best Practices
```yaml
services:
  web:
    # Use specific image tags
    image: nginx:1.21-alpine
    
    # Run as non-root user
    user: "1000:1000"
    
    # Read-only root filesystem
    read_only: true
    tmpfs:
      - /tmp
      - /var/cache/nginx
    
    # Drop capabilities
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - SETGID
      - SETUID
    
    # Security options
    security_opt:
      - no-new-privileges:true
```

### Production Considerations
```yaml
services:
  web:
    # Restart policy
    restart: unless-stopped
    
    # Resource limits
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
    
    # Health checks
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    
    # Logging configuration
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## Troubleshooting

### Common Issues
```bash
# View service logs
docker-compose logs service_name

# Check service status
docker-compose ps

# Inspect networks
docker network ls
docker network inspect project_default

# Check volumes
docker volume ls
docker volume inspect project_volume_name

# Validate compose file
docker-compose config

# Force recreate services
docker-compose up -d --force-recreate
```

### Debugging Commands
```bash
# Run command in service
docker-compose exec web bash

# Run one-off container
docker-compose run --rm web bash

# Check environment variables
docker-compose exec web env

# Test network connectivity
docker-compose exec web ping db
docker-compose exec web nslookup db
```

This comprehensive guide covers Docker Compose from basic concepts to advanced production deployments with real-world examples and best practices.