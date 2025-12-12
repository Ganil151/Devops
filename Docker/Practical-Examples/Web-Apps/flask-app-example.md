# Flask Web Application with Docker

Complete example of containerizing a Python Flask web application based on the existing project.

## Project Structure

```
flask-app/
├── Dockerfile
├── requirements.txt
├── index.py
├── .dockerignore
└── docker-compose.yml
```

## Application Code

### index.py
```python
from flask import Flask, jsonify, request
import os

app = Flask(__name__)

@app.route("/")
def home():
    return {"message": "Hey there Python Flask!", "status": "running"}

@app.route("/health")
def health():
    return {"status": "healthy", "version": "1.0.0"}

@app.route("/api/data")
def get_data():
    return {
        "data": ["item1", "item2", "item3"],
        "count": 3,
        "environment": os.getenv("FLASK_ENV", "production")
    }

@app.route("/api/echo", methods=["POST"])
def echo():
    data = request.get_json()
    return {"echo": data, "received": True}

if __name__ == "__main__":
    port = int(os.getenv("PORT", 3000))
    debug = os.getenv("FLASK_ENV") == "development"
    app.run(host="0.0.0.0", port=port, debug=debug)
```

### requirements.txt
```txt
Flask==2.3.3
gunicorn==21.2.0
```

## Dockerfile (Enhanced Version)

### Basic Dockerfile
```dockerfile
FROM python:3.11-alpine

# Set working directory
WORKDIR /app

# Copy requirements first (for better caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN adduser -D -s /bin/sh appuser
USER appuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Run application
CMD ["python", "index.py"]
```

### Production Dockerfile
```dockerfile
# Multi-stage build for production
FROM python:3.11-alpine AS builder

# Install build dependencies
RUN apk add --no-cache gcc musl-dev

# Set working directory
WORKDIR /app

# Copy and install requirements
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.11-alpine AS production

# Install runtime dependencies
RUN apk add --no-cache curl && \
    adduser -D -s /bin/sh appuser

# Copy installed packages from builder
COPY --from=builder /root/.local /home/appuser/.local

# Set working directory
WORKDIR /app

# Copy application code
COPY --chown=appuser:appuser . .

# Switch to non-root user
USER appuser

# Update PATH
ENV PATH=/home/appuser/.local/bin:$PATH

# Set environment variables
ENV FLASK_ENV=production
ENV PORT=3000

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Use gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:3000", "--workers", "4", "index:app"]
```

## Docker Compose Configuration

### docker-compose.yml
```yaml
version: '3.8'

services:
  flask-app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - FLASK_ENV=development
      - PORT=3000
    volumes:
      - .:/app
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - flask-app
    restart: unless-stopped
```

### Production docker-compose.yml
```yaml
version: '3.8'

services:
  flask-app:
    build:
      context: .
      target: production
    ports:
      - "3000:3000"
    environment:
      - FLASK_ENV=production
      - PORT=3000
      - REDIS_URL=redis://redis:6379
    depends_on:
      - redis
    restart: unless-stopped
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped
    command: redis-server --appendonly yes

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - flask-app
    restart: unless-stopped

volumes:
  redis_data:
```

## Nginx Configuration

### nginx.conf
```nginx
events {
    worker_connections 1024;
}

http {
    upstream flask_app {
        server flask-app:3000;
    }

    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://flask_app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /health {
            access_log off;
            proxy_pass http://flask_app;
        }
    }
}
```

## .dockerignore File

```
# .dockerignore
__pycache__
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.venv/
pip-log.txt
pip-delete-this-directory.txt
.tox
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.log
.git
.mypy_cache
.pytest_cache
.hypothesis

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Docker
Dockerfile*
docker-compose*
.dockerignore
```

## Build and Run Commands

### Basic Commands
```bash
# Build image
docker build -t flask-app:latest .

# Run container
docker run -d -p 3000:3000 --name flask-app flask-app:latest

# View logs
docker logs -f flask-app

# Test application
curl http://localhost:3000
curl http://localhost:3000/health
curl http://localhost:3000/api/data
```

### Docker Compose Commands
```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f flask-app

# Scale application
docker-compose up -d --scale flask-app=3

# Stop services
docker-compose down

# Rebuild and start
docker-compose up -d --build
```

## Advanced Features

### Environment-Specific Builds
```bash
# Development build
docker build --target builder -t flask-app:dev .

# Production build
docker build --target production -t flask-app:prod .

# Build with build args
docker build --build-arg FLASK_ENV=production -t flask-app:prod .
```

### Multi-Environment Compose
```yaml
# docker-compose.override.yml (for development)
version: '3.8'

services:
  flask-app:
    build:
      target: builder
    environment:
      - FLASK_ENV=development
      - FLASK_DEBUG=1
    volumes:
      - .:/app
    command: python index.py
```

### Health Monitoring
```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' flask-app

# Monitor health logs
docker inspect --format='{{json .State.Health}}' flask-app | jq
```

## Security Enhancements

### Secure Dockerfile
```dockerfile
FROM python:3.11-alpine AS production

# Security updates
RUN apk update && apk upgrade && \
    apk add --no-cache curl && \
    rm -rf /var/cache/apk/*

# Create non-root user with specific UID/GID
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy and install requirements as root
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code and set ownership
COPY --chown=appuser:appgroup . .

# Switch to non-root user
USER appuser

# Set security-focused environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV FLASK_ENV=production

# Use non-root port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Run with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", "--user", "appuser", "--group", "appgroup", "index:app"]
```

## Monitoring and Logging

### Structured Logging
```python
import logging
import json
from datetime import datetime

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(message)s'
)

logger = logging.getLogger(__name__)

def log_request(request):
    log_data = {
        'timestamp': datetime.utcnow().isoformat(),
        'method': request.method,
        'path': request.path,
        'remote_addr': request.remote_addr,
        'user_agent': request.headers.get('User-Agent')
    }
    logger.info(json.dumps(log_data))

@app.before_request
def before_request():
    log_request(request)
```

### Docker Logging Configuration
```yaml
# docker-compose.yml with logging
services:
  flask-app:
    build: .
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    # Or use external logging driver
    # logging:
    #   driver: "syslog"
    #   options:
    #     syslog-address: "tcp://logserver:514"
```

## Testing

### Test Dockerfile
```dockerfile
FROM python:3.11-alpine AS test

WORKDIR /app

# Install test dependencies
COPY requirements.txt requirements-test.txt ./
RUN pip install -r requirements.txt -r requirements-test.txt

# Copy source code
COPY . .

# Run tests
CMD ["python", "-m", "pytest", "-v"]
```

### Test Commands
```bash
# Build test image
docker build --target test -t flask-app:test .

# Run tests
docker run --rm flask-app:test

# Run tests with coverage
docker run --rm -v $(pwd)/coverage:/app/coverage flask-app:test \
    python -m pytest --cov=. --cov-report=html:/app/coverage
```

This comprehensive example demonstrates containerizing a Flask application with production-ready configurations, security best practices, and monitoring capabilities.