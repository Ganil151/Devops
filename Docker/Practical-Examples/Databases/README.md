# Database Containers

Complete guide to running databases in Docker containers with production-ready configurations.

## PostgreSQL

### Basic PostgreSQL Setup

```bash
# Run PostgreSQL container
docker run -d \
  --name postgres-db \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  postgres:13

# Connect to database
docker exec -it postgres-db psql -U postgres

# Create database and user
CREATE DATABASE myapp;
CREATE USER myuser WITH PASSWORD 'mypassword';
GRANT ALL PRIVILEGES ON DATABASE myapp TO myuser;
```

### Production PostgreSQL Configuration

```bash
# Create volume for data persistence
docker volume create postgres-data

# Run with production settings
docker run -d \
  --name postgres-prod \
  --restart unless-stopped \
  -e POSTGRES_DB=production_db \
  -e POSTGRES_USER=app_user \
  -e POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password \
  -v postgres-data:/var/lib/postgresql/data \
  -v /host/config/postgresql.conf:/etc/postgresql/postgresql.conf:ro \
  -v /host/config/pg_hba.conf:/etc/postgresql/pg_hba.conf:ro \
  --memory=2g \
  --cpus="2" \
  -p 5432:5432 \
  postgres:13 \
  -c config_file=/etc/postgresql/postgresql.conf
```

### PostgreSQL with Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:13
    container_name: postgres-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-myapp}
      POSTGRES_USER: ${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d:ro
      - ./config/postgresql.conf:/etc/postgresql/postgresql.conf:ro
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-postgres}"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '2'
        reservations:
          memory: 1G
          cpus: '1'

volumes:
  postgres-data:
```

## MySQL

### Basic MySQL Setup

```bash
# Run MySQL container
docker run -d \
  --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=myapp \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=apppassword \
  -p 3306:3306 \
  mysql:8.0

# Connect to database
docker exec -it mysql-db mysql -u root -p
```

### Production MySQL Configuration

```bash
# Create volume for data
docker volume create mysql-data

# Run with production settings
docker run -d \
  --name mysql-prod \
  --restart unless-stopped \
  -e MYSQL_ROOT_PASSWORD_FILE=/run/secrets/mysql_root_password \
  -e MYSQL_DATABASE=production_db \
  -e MYSQL_USER=app_user \
  -e MYSQL_PASSWORD_FILE=/run/secrets/mysql_password \
  -v mysql-data:/var/lib/mysql \
  -v /host/config/my.cnf:/etc/mysql/my.cnf:ro \
  --memory=2g \
  --cpus="2" \
  -p 3306:3306 \
  mysql:8.0
```

### MySQL Configuration File

```ini
# my.cnf
[mysqld]
# Basic settings
bind-address = 0.0.0.0
port = 3306
datadir = /var/lib/mysql
socket = /var/run/mysqld/mysqld.sock

# Performance tuning
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT

# Connection settings
max_connections = 200
max_connect_errors = 10000
wait_timeout = 28800
interactive_timeout = 28800

# Logging
log-error = /var/log/mysql/error.log
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2

# Security
local-infile = 0
```

## MongoDB

### Basic MongoDB Setup

```bash
# Run MongoDB container
docker run -d \
  --name mongo-db \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=password \
  -p 27017:27017 \
  mongo:5.0

# Connect to MongoDB
docker exec -it mongo-db mongo -u admin -p password --authenticationDatabase admin
```

### Production MongoDB Configuration

```bash
# Create volume for data
docker volume create mongo-data

# Run with production settings
docker run -d \
  --name mongo-prod \
  --restart unless-stopped \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD_FILE=/run/secrets/mongo_password \
  -e MONGO_INITDB_DATABASE=production_db \
  -v mongo-data:/data/db \
  -v /host/config/mongod.conf:/etc/mongod.conf:ro \
  --memory=2g \
  --cpus="2" \
  -p 27017:27017 \
  mongo:5.0 \
  --config /etc/mongod.conf
```

### MongoDB with Replica Set

```yaml
# docker-compose.yml for MongoDB replica set
version: '3.8'

services:
  mongo1:
    image: mongo:5.0
    container_name: mongo1
    restart: unless-stopped
    command: mongod --replSet rs0 --bind_ip_all
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password
    volumes:
      - mongo1-data:/data/db
    ports:
      - "27017:27017"

  mongo2:
    image: mongo:5.0
    container_name: mongo2
    restart: unless-stopped
    command: mongod --replSet rs0 --bind_ip_all
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password
    volumes:
      - mongo2-data:/data/db
    ports:
      - "27018:27017"

  mongo3:
    image: mongo:5.0
    container_name: mongo3
    restart: unless-stopped
    command: mongod --replSet rs0 --bind_ip_all
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password
    volumes:
      - mongo3-data:/data/db
    ports:
      - "27019:27017"

volumes:
  mongo1-data:
  mongo2-data:
  mongo3-data:
```

## Redis

### Basic Redis Setup

```bash
# Run Redis container
docker run -d \
  --name redis-cache \
  -p 6379:6379 \
  redis:7-alpine

# Connect to Redis
docker exec -it redis-cache redis-cli
```

### Production Redis Configuration

```bash
# Create volume for persistence
docker volume create redis-data

# Run with persistence and configuration
docker run -d \
  --name redis-prod \
  --restart unless-stopped \
  -v redis-data:/data \
  -v /host/config/redis.conf:/etc/redis/redis.conf:ro \
  --memory=1g \
  --cpus="1" \
  -p 6379:6379 \
  redis:7-alpine \
  redis-server /etc/redis/redis.conf
```

### Redis Configuration

```conf
# redis.conf
# Network
bind 0.0.0.0
port 6379
timeout 300
keepalive 60

# Memory management
maxmemory 512mb
maxmemory-policy allkeys-lru

# Persistence
save 900 1
save 300 10
save 60 10000
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /data

# Append only file
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec

# Security
requirepass your_secure_password

# Logging
loglevel notice
logfile /var/log/redis/redis-server.log
```

## Elasticsearch

### Basic Elasticsearch Setup

```bash
# Run Elasticsearch container
docker run -d \
  --name elasticsearch \
  -e "discovery.type=single-node" \
  -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
  -p 9200:9200 \
  -p 9300:9300 \
  elasticsearch:7.17.0

# Test connection
curl http://localhost:9200
```

### Production Elasticsearch Cluster

```yaml
# docker-compose.yml for Elasticsearch cluster
version: '3.8'

services:
  es01:
    image: elasticsearch:7.17.0
    container_name: es01
    environment:
      - node.name=es01
      - cluster.name=es-docker-cluster
      - discovery.seed_hosts=es02,es03
      - cluster.initial_master_nodes=es01,es02,es03
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - es01-data:/usr/share/elasticsearch/data
    ports:
      - 9200:9200
    networks:
      - elastic

  es02:
    image: elasticsearch:7.17.0
    container_name: es02
    environment:
      - node.name=es02
      - cluster.name=es-docker-cluster
      - discovery.seed_hosts=es01,es03
      - cluster.initial_master_nodes=es01,es02,es03
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - es02-data:/usr/share/elasticsearch/data
    networks:
      - elastic

  es03:
    image: elasticsearch:7.17.0
    container_name: es03
    environment:
      - node.name=es03
      - cluster.name=es-docker-cluster
      - discovery.seed_hosts=es01,es02
      - cluster.initial_master_nodes=es01,es02,es03
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - es03-data:/usr/share/elasticsearch/data
    networks:
      - elastic

volumes:
  es01-data:
  es02-data:
  es03-data:

networks:
  elastic:
    driver: bridge
```

## Database Networking Example

### Multi-Database Application

```yaml
# docker-compose.yml with multiple databases
version: '3.8'

services:
  # Web application
  webapp:
    image: myapp:latest
    container_name: webapp
    restart: unless-stopped
    environment:
      - DB_HOST=postgres
      - REDIS_HOST=redis
      - MONGO_HOST=mongo
    ports:
      - "3000:3000"
    depends_on:
      - postgres
      - redis
      - mongo
    networks:
      - app-network

  # PostgreSQL for main application data
  postgres:
    image: postgres:13
    container_name: postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Redis for caching
  redis:
    image: redis:7-alpine
    container_name: redis
    restart: unless-stopped
    volumes:
      - redis-data:/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  # MongoDB for document storage
  mongo:
    image: mongo:5.0
    container_name: mongo
    restart: unless-stopped
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD}
    volumes:
      - mongo-data:/data/db
    networks:
      - app-network
    healthcheck:
      test: echo 'db.runCommand("ping").ok' | mongo localhost:27017/test --quiet
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  postgres-data:
  redis-data:
  mongo-data:

networks:
  app-network:
    driver: bridge
```

## Database Backup and Restore

### PostgreSQL Backup

```bash
# Backup database
docker exec postgres-db pg_dump -U postgres myapp > backup.sql

# Backup with compression
docker exec postgres-db pg_dump -U postgres myapp | gzip > backup.sql.gz

# Restore database
docker exec -i postgres-db psql -U postgres myapp < backup.sql

# Automated backup script
#!/bin/bash
BACKUP_DIR="/backups/postgres"
DATE=$(date +%Y%m%d_%H%M%S)
docker exec postgres-db pg_dump -U postgres myapp | gzip > "$BACKUP_DIR/backup_$DATE.sql.gz"
```

### MySQL Backup

```bash
# Backup database
docker exec mysql-db mysqldump -u root -p myapp > backup.sql

# Backup all databases
docker exec mysql-db mysqldump -u root -p --all-databases > all_databases.sql

# Restore database
docker exec -i mysql-db mysql -u root -p myapp < backup.sql
```

### MongoDB Backup

```bash
# Backup database
docker exec mongo-db mongodump --db myapp --out /backup

# Backup with authentication
docker exec mongo-db mongodump --host localhost --port 27017 \
  --username admin --password password --authenticationDatabase admin \
  --db myapp --out /backup

# Restore database
docker exec mongo-db mongorestore --db myapp /backup/myapp
```

## Database Monitoring

### Health Checks

```bash
# PostgreSQL health check
docker exec postgres-db pg_isready -U postgres

# MySQL health check
docker exec mysql-db mysqladmin ping -u root -p

# MongoDB health check
docker exec mongo-db mongo --eval "db.adminCommand('ping')"

# Redis health check
docker exec redis-cache redis-cli ping
```

### Performance Monitoring

```bash
# Monitor database containers
docker stats postgres-db mysql-db mongo-db redis-cache

# Database-specific monitoring
docker exec postgres-db psql -U postgres -c "SELECT * FROM pg_stat_activity;"
docker exec mysql-db mysql -u root -p -e "SHOW PROCESSLIST;"
docker exec mongo-db mongo --eval "db.currentOp()"
```