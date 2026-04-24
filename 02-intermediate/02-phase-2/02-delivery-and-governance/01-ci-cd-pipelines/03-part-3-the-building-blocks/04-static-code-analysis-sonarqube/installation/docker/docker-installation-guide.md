# SonarQube Docker Installation Guide

Complete guide for running SonarQube with Docker and Docker Compose, including production-ready configurations.

## Quick Start (Development)

### Simple Docker Run
```bash
# Basic SonarQube with H2 database (development only)
docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  sonarqube:latest
```

**⚠️ Warning**: This uses H2 database which is NOT suitable for production use.

## Production Setup with PostgreSQL

### Method 1: Docker Compose (Recommended)

Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  sonarqube:
    image: sonarqube:10.3-community
    container_name: sonarqube
    restart: unless-stopped
    ports:
      - "9000:9000"
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://db:5432/sonarqube
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: sonar_password
      SONAR_ES_BOOTSTRAP_CHECKS_DISABLE: "false"
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
      - sonarqube_conf:/opt/sonarqube/conf
    depends_on:
      - db
    networks:
      - sonarqube-network
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 131072
        hard: 131072
      nproc:
        soft: 8192
        hard: 8192

  db:
    image: postgres:15-alpine
    container_name: sonarqube_db
    restart: unless-stopped
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar_password
      POSTGRES_DB: sonarqube
    volumes:
      - postgresql_data:/var/lib/postgresql/data
    networks:
      - sonarqube-network
    command: >
      postgres
      -c shared_buffers=256MB
      -c max_connections=300
      -c effective_cache_size=1GB

volumes:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
  sonarqube_conf:
  postgresql_data:

networks:
  sonarqube-network:
    driver: bridge
```

### Deploy with Docker Compose
```bash
# Create project directory
mkdir sonarqube-docker && cd sonarqube-docker

# Create docker-compose.yml (content above)
nano docker-compose.yml

# Set system limits (required for Elasticsearch)
echo 'vm.max_map_count=524288' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Start services
docker-compose up -d

# Check logs
docker-compose logs -f sonarqube
```

### Method 2: Separate Docker Commands

#### Start PostgreSQL Container
```bash
# Create network
docker network create sonarqube-network

# Start PostgreSQL
docker run -d \
  --name sonarqube_db \
  --network sonarqube-network \
  -e POSTGRES_USER=sonar \
  -e POSTGRES_PASSWORD=sonar_password \
  -e POSTGRES_DB=sonarqube \
  -v postgresql_data:/var/lib/postgresql/data \
  postgres:15-alpine
```

#### Start SonarQube Container
```bash
# Set system limits
echo 'vm.max_map_count=524288' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Start SonarQube
docker run -d \
  --name sonarqube \
  --network sonarqube-network \
  -p 9000:9000 \
  -e SONAR_JDBC_URL=jdbc:postgresql://sonarqube_db:5432/sonarqube \
  -e SONAR_JDBC_USERNAME=sonar \
  -e SONAR_JDBC_PASSWORD=sonar_password \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -v sonarqube_logs:/opt/sonarqube/logs \
  --ulimit nofile=131072:131072 \
  --ulimit nproc=8192:8192 \
  sonarqube:10.3-community
```

## Advanced Configuration

### Environment Variables
```yaml
# Complete environment configuration
environment:
  # Database Configuration
  SONAR_JDBC_URL: jdbc:postgresql://db:5432/sonarqube
  SONAR_JDBC_USERNAME: sonar
  SONAR_JDBC_PASSWORD: sonar_password
  
  # Web Server Configuration
  SONAR_WEB_HOST: 0.0.0.0
  SONAR_WEB_PORT: 9000
  SONAR_WEB_CONTEXT: /
  
  # JVM Options
  SONAR_WEB_JAVAOPTS: -Xmx2G -Xms1G -XX:+UseG1GC
  SONAR_SEARCH_JAVAOPTS: -Xmx1G -Xms1G -XX:+UseG1GC
  
  # Elasticsearch Configuration
  SONAR_ES_BOOTSTRAP_CHECKS_DISABLE: "false"
  
  # Security
  SONAR_SECURITY_REALM: LDAP
  SONAR_AUTHENTICATOR_DOWNCASE: "true"
  
  # Logging
  SONAR_LOG_LEVEL: INFO
```

### Custom Configuration Files

#### Create custom sonar.properties
```bash
# Create configuration directory
mkdir -p ./config

# Create custom sonar.properties
cat > ./config/sonar.properties << EOF
# Database
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar_password
sonar.jdbc.url=jdbc:postgresql://db:5432/sonarqube

# Web Server
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.web.javaAdditionalOpts=-server -Xmx2G -Xms1G

# Search Engine
sonar.search.javaOpts=-Xmx1G -Xms1G

# Security
sonar.forceAuthentication=true
sonar.security.realm=LDAP

# Performance
sonar.web.http.maxThreads=50
sonar.web.http.minThreads=5
sonar.web.http.acceptCount=25
EOF
```

#### Mount custom configuration
```yaml
# In docker-compose.yml
volumes:
  - ./config/sonar.properties:/opt/sonarqube/conf/sonar.properties:ro
  - sonarqube_data:/opt/sonarqube/data
  - sonarqube_extensions:/opt/sonarqube/extensions
  - sonarqube_logs:/opt/sonarqube/logs
```

## SSL/HTTPS Configuration

### Using Reverse Proxy (Recommended)

#### Nginx Reverse Proxy
```yaml
# Add nginx service to docker-compose.yml
  nginx:
    image: nginx:alpine
    container_name: sonarqube_nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - sonarqube
    networks:
      - sonarqube-network
```

#### Nginx Configuration
```nginx
# nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream sonarqube {
        server sonarqube:9000;
    }

    server {
        listen 80;
        server_name your-domain.com;
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name your-domain.com;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        client_max_body_size 50M;

        location / {
            proxy_pass http://sonarqube;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### Direct HTTPS in SonarQube
```yaml
# Environment variables for HTTPS
environment:
  SONAR_WEB_HTTPS_PORT: 9443
  SONAR_WEB_HTTPS_KEYSTORE: /opt/sonarqube/conf/sonarqube.p12
  SONAR_WEB_HTTPS_KEYSTORE_PASSWORD: your_keystore_password
  SONAR_WEB_HTTP_PORT: -1  # Disable HTTP

# Mount SSL certificate
volumes:
  - ./ssl/sonarqube.p12:/opt/sonarqube/conf/sonarqube.p12:ro
```

## Monitoring and Logging

### Health Check Configuration
```yaml
# Add to sonarqube service
healthcheck:
  test: ["CMD-SHELL", "curl -f http://localhost:9000/api/system/status || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

### Logging Configuration
```yaml
# Centralized logging with ELK stack
  elasticsearch:
    image: elasticsearch:7.17.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

  logstash:
    image: logstash:7.17.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf:ro
    depends_on:
      - elasticsearch

  kibana:
    image: kibana:7.17.0
    ports:
      - "5601:5601"
    environment:
      ELASTICSEARCH_HOSTS: http://elasticsearch:9200
    depends_on:
      - elasticsearch
```

## Backup and Restore

### Database Backup
```bash
# Backup PostgreSQL database
docker exec sonarqube_db pg_dump -U sonar sonarqube > sonarqube_backup_$(date +%Y%m%d_%H%M%S).sql

# Automated backup script
cat > backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backups/sonarqube"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Database backup
docker exec sonarqube_db pg_dump -U sonar sonarqube > $BACKUP_DIR/db_backup_$DATE.sql

# Volume backup
docker run --rm -v sonarqube_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/data_backup_$DATE.tar.gz -C /data .

# Cleanup old backups (keep last 7 days)
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
EOF

chmod +x backup.sh
```

### Restore Process
```bash
# Stop SonarQube
docker-compose stop sonarqube

# Restore database
docker exec -i sonarqube_db psql -U sonar sonarqube < sonarqube_backup_20241201_120000.sql

# Restore data volume
docker run --rm -v sonarqube_data:/data -v /backups/sonarqube:/backup alpine tar xzf /backup/data_backup_20241201_120000.tar.gz -C /data

# Start SonarQube
docker-compose start sonarqube
```

## Performance Tuning

### Resource Limits
```yaml
# Resource constraints
services:
  sonarqube:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 4G
        reservations:
          cpus: '1.0'
          memory: 2G
```

### JVM Tuning
```yaml
environment:
  # Web server JVM options
  SONAR_WEB_JAVAOPTS: >
    -Xmx4G
    -Xms2G
    -XX:+UseG1GC
    -XX:MaxGCPauseMillis=200
    -XX:+UnlockExperimentalVMOptions
    -XX:+UseCGroupMemoryLimitForHeap
  
  # Elasticsearch JVM options
  SONAR_SEARCH_JAVAOPTS: >
    -Xmx2G
    -Xms2G
    -XX:+UseG1GC
    -XX:MaxGCPauseMillis=200
```

## Troubleshooting

### Common Issues

#### Elasticsearch Bootstrap Checks
```bash
# Set system limits
echo 'vm.max_map_count=524288' | sudo tee -a /etc/sysctl.conf
echo 'fs.file-max=131072' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# For development only
SONAR_ES_BOOTSTRAP_CHECKS_DISABLE: "true"
```

#### Memory Issues
```bash
# Check container memory usage
docker stats sonarqube

# Increase memory limits
SONAR_WEB_JAVAOPTS: -Xmx4G -Xms2G
SONAR_SEARCH_JAVAOPTS: -Xmx2G -Xms2G
```

#### Database Connection Issues
```bash
# Check database connectivity
docker exec sonarqube_db psql -U sonar -d sonarqube -c "SELECT version();"

# Check network connectivity
docker exec sonarqube ping sonarqube_db
```

### Debugging Commands
```bash
# View logs
docker-compose logs -f sonarqube
docker-compose logs -f db

# Execute commands in container
docker exec -it sonarqube bash
docker exec -it sonarqube_db psql -U sonar sonarqube

# Check container health
docker inspect sonarqube | grep -A 10 "Health"

# Monitor resource usage
docker stats --no-stream
```

## Security Best Practices

### Container Security
```yaml
# Security configurations
services:
  sonarqube:
    user: "1000:1000"  # Non-root user
    read_only: true     # Read-only filesystem
    tmpfs:
      - /tmp
      - /opt/sonarqube/temp
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - SETGID
      - SETUID
```

### Network Security
```yaml
# Isolated network
networks:
  sonarqube-network:
    driver: bridge
    internal: true  # No external access
  
  web-network:
    driver: bridge  # Only for reverse proxy
```

This completes the comprehensive Docker installation guide for SonarQube with production-ready configurations, security hardening, and troubleshooting information.