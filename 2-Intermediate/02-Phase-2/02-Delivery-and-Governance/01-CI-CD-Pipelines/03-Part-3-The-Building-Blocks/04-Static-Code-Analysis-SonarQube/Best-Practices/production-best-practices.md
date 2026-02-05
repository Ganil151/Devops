# SonarQube Production Best Practices

Comprehensive guide for deploying, configuring, and maintaining SonarQube in production environments.

## Infrastructure Best Practices

### Hardware Requirements

#### Minimum Production Setup
```
CPU: 4 cores (8 recommended)
RAM: 8GB (16GB recommended)
Storage: 50GB SSD (100GB+ for large organizations)
Network: 1Gbps connection
```

#### Large Enterprise Setup
```
CPU: 8+ cores
RAM: 32GB+
Storage: 200GB+ NVMe SSD
Database: Dedicated PostgreSQL cluster
Load Balancer: For high availability
```

### Database Configuration

#### PostgreSQL Optimization
```sql
-- postgresql.conf optimizations
shared_buffers = 2GB                    # 25% of RAM
effective_cache_size = 6GB              # 75% of RAM
work_mem = 64MB                         # For complex queries
maintenance_work_mem = 512MB            # For maintenance operations
checkpoint_completion_target = 0.9      # Smooth checkpoints
wal_buffers = 16MB                      # WAL buffer size
random_page_cost = 1.1                  # For SSD storage
effective_io_concurrency = 200          # For SSD storage

# Connection settings
max_connections = 300                   # Adjust based on load
shared_preload_libraries = 'pg_stat_statements'

# Logging
log_min_duration_statement = 1000       # Log slow queries
log_checkpoints = on
log_connections = on
log_disconnections = on
```

#### Database Maintenance
```bash
#!/bin/bash
# Daily maintenance script

# Vacuum and analyze
psql -d sonarqube -c "VACUUM ANALYZE;"

# Update statistics
psql -d sonarqube -c "ANALYZE;"

# Check database size
psql -d sonarqube -c "
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 10;"

# Backup database
pg_dump sonarqube > /backups/sonarqube_$(date +%Y%m%d_%H%M%S).sql
```

## Security Hardening

### Authentication and Authorization

#### LDAP Integration
```properties
# sonar.properties - LDAP configuration
sonar.security.realm=LDAP
sonar.authenticator.downcase=true

# LDAP server configuration
ldap.url=ldaps://ldap.company.com:636
ldap.bindDn=cn=sonar,ou=services,dc=company,dc=com
ldap.bindPassword=secure_password

# User configuration
ldap.user.baseDn=ou=users,dc=company,dc=com
ldap.user.request=(&(objectClass=inetOrgPerson)(uid={login}))
ldap.user.realNameAttribute=displayName
ldap.user.emailAttribute=mail

# Group configuration
ldap.group.baseDn=ou=groups,dc=company,dc=com
ldap.group.request=(&(objectClass=groupOfNames)(member={dn}))
ldap.group.idAttribute=cn
```

#### SAML Integration
```properties
# SAML configuration
sonar.auth.saml.enabled=true
sonar.auth.saml.applicationId=sonarqube
sonar.auth.saml.providerName=Company SSO
sonar.auth.saml.providerId=https://sso.company.com
sonar.auth.saml.loginUrl=https://sso.company.com/saml/login
sonar.auth.saml.certificate.secured=MIICertificateContent...
sonar.auth.saml.user.login=login
sonar.auth.saml.user.name=name
sonar.auth.saml.user.email=email
sonar.auth.saml.group.name=groups
```

### Network Security

#### Reverse Proxy Configuration (Nginx)
```nginx
# /etc/nginx/sites-available/sonarqube
upstream sonarqube {
    server 127.0.0.1:9000;
}

server {
    listen 80;
    server_name sonarqube.company.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name sonarqube.company.com;

    # SSL Configuration
    ssl_certificate /etc/ssl/certs/sonarqube.crt;
    ssl_certificate_key /etc/ssl/private/sonarqube.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-Frame-Options DENY always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Rate Limiting
    limit_req_zone $binary_remote_addr zone=sonar_login:10m rate=5r/m;
    limit_req_zone $binary_remote_addr zone=sonar_api:10m rate=100r/m;

    # Client settings
    client_max_body_size 50M;
    client_body_timeout 60s;
    client_header_timeout 60s;

    location / {
        proxy_pass http://sonarqube;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Buffer settings
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
    }

    location /api/authentication/login {
        limit_req zone=sonar_login burst=3 nodelay;
        proxy_pass http://sonarqube;
        # ... other proxy settings
    }

    location /api/ {
        limit_req zone=sonar_api burst=20 nodelay;
        proxy_pass http://sonarqube;
        # ... other proxy settings
    }
}
```

#### Firewall Configuration
```bash
# UFW firewall rules
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow from 10.0.0.0/8 to any port 5432  # PostgreSQL from internal network
sudo ufw enable

# iptables rules (alternative)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -s 10.0.0.0/8 -p tcp --dport 5432 -j ACCEPT
iptables -A INPUT -j DROP
```

## Performance Optimization

### JVM Tuning

#### Production JVM Settings
```properties
# sonar.properties - JVM optimization
sonar.web.javaAdditionalOpts=-server \
  -Xmx8G \
  -Xms4G \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=200 \
  -XX:+UnlockExperimentalVMOptions \
  -XX:+UseCGroupMemoryLimitForHeap \
  -XX:NewRatio=1 \
  -XX:+PrintGCDetails \
  -XX:+PrintGCTimeStamps \
  -Xloggc:/opt/sonarqube/logs/gc.log \
  -XX:+UseGCLogFileRotation \
  -XX:NumberOfGCLogFiles=5 \
  -XX:GCLogFileSize=100M

sonar.search.javaOpts=-Xmx4G \
  -Xms4G \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=200 \
  -XX:+UnlockExperimentalVMOptions \
  -XX:+UseCGroupMemoryLimitForHeap
```

#### Memory Monitoring Script
```bash
#!/bin/bash
# monitor-sonarqube-memory.sh

SONAR_PID=$(pgrep -f "sonar.application.app=SonarQube")

if [ -n "$SONAR_PID" ]; then
    echo "SonarQube Memory Usage - $(date)"
    echo "================================"
    
    # JVM memory usage
    jstat -gc $SONAR_PID
    
    # Heap dump on high memory usage
    HEAP_USAGE=$(jstat -gc $SONAR_PID | tail -1 | awk '{print ($3+$4+$6+$8)/($1+$2+$5+$7)*100}')
    
    if (( $(echo "$HEAP_USAGE > 90" | bc -l) )); then
        echo "High memory usage detected: ${HEAP_USAGE}%"
        jmap -dump:format=b,file=/tmp/sonarqube-heap-$(date +%Y%m%d_%H%M%S).hprof $SONAR_PID
    fi
else
    echo "SonarQube process not found"
fi
```

### Database Performance

#### Index Optimization
```sql
-- Create additional indexes for better performance
CREATE INDEX CONCURRENTLY idx_projects_enabled ON projects(enabled) WHERE enabled = true;
CREATE INDEX CONCURRENTLY idx_issues_creation_date ON issues(issue_creation_date);
CREATE INDEX CONCURRENTLY idx_snapshots_created_at ON snapshots(created_at);
CREATE INDEX CONCURRENTLY idx_measures_component_uuid ON project_measures(component_uuid);

-- Analyze query performance
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM issues 
WHERE component_uuid = 'uuid' 
AND issue_creation_date > NOW() - INTERVAL '30 days';
```

#### Connection Pool Tuning
```properties
# Database connection pool settings
sonar.jdbc.maxActive=60
sonar.jdbc.maxIdle=5
sonar.jdbc.minIdle=2
sonar.jdbc.maxWait=5000
sonar.jdbc.minEvictableIdleTimeMillis=600000
sonar.jdbc.timeBetweenEvictionRunsMillis=30000
```

## Monitoring and Alerting

### System Monitoring

#### Prometheus Metrics
```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'sonarqube'
    static_configs:
      - targets: ['sonarqube:9000']
    metrics_path: '/api/monitoring/metrics'
    scrape_interval: 30s
```

#### Custom Metrics Collection
```bash
#!/bin/bash
# collect-sonarqube-metrics.sh

SONAR_URL="http://localhost:9000"
SONAR_TOKEN="your-token"
METRICS_FILE="/var/lib/node_exporter/textfile_collector/sonarqube.prom"

# System status
STATUS=$(curl -s -u ${SONAR_TOKEN}: "${SONAR_URL}/api/system/status" | jq -r '.status')

# Database connection pool
DB_POOL=$(curl -s -u ${SONAR_TOKEN}: "${SONAR_URL}/api/system/db_connection_usage" | jq '.pool_active_connections')

# JVM metrics
JVM_HEAP=$(curl -s -u ${SONAR_TOKEN}: "${SONAR_URL}/api/system/info" | jq '.["System"]["Heap Memory Usage"]' | sed 's/%//')

# Write metrics
cat > $METRICS_FILE << EOF
# HELP sonarqube_status SonarQube system status
# TYPE sonarqube_status gauge
sonarqube_status{status="$STATUS"} $([ "$STATUS" = "UP" ] && echo 1 || echo 0)

# HELP sonarqube_db_connections Database connection pool usage
# TYPE sonarqube_db_connections gauge
sonarqube_db_connections $DB_POOL

# HELP sonarqube_jvm_heap_usage JVM heap memory usage percentage
# TYPE sonarqube_jvm_heap_usage gauge
sonarqube_jvm_heap_usage $JVM_HEAP
EOF
```

### Log Management

#### Centralized Logging (ELK Stack)
```yaml
# filebeat.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /opt/sonarqube/logs/*.log
  fields:
    service: sonarqube
    environment: production
  multiline.pattern: '^\d{4}\.\d{2}\.\d{2}'
  multiline.negate: true
  multiline.match: after

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
  index: "sonarqube-logs-%{+yyyy.MM.dd}"

processors:
- add_host_metadata:
    when.not.contains.tags: forwarded
```

#### Log Rotation
```bash
# /etc/logrotate.d/sonarqube
/opt/sonarqube/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 sonarqube sonarqube
    postrotate
        systemctl reload sonarqube
    endscript
}
```

## Backup and Disaster Recovery

### Automated Backup Strategy

#### Database Backup Script
```bash
#!/bin/bash
# backup-sonarqube.sh

BACKUP_DIR="/backups/sonarqube"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

mkdir -p $BACKUP_DIR

# Database backup
echo "Starting database backup..."
pg_dump -h localhost -U sonar sonarqube | gzip > $BACKUP_DIR/sonarqube_db_$DATE.sql.gz

# Data directory backup
echo "Starting data directory backup..."
tar -czf $BACKUP_DIR/sonarqube_data_$DATE.tar.gz -C /opt/sonarqube data extensions conf

# Upload to S3 (optional)
if [ -n "$AWS_S3_BUCKET" ]; then
    aws s3 cp $BACKUP_DIR/sonarqube_db_$DATE.sql.gz s3://$AWS_S3_BUCKET/sonarqube/
    aws s3 cp $BACKUP_DIR/sonarqube_data_$DATE.tar.gz s3://$AWS_S3_BUCKET/sonarqube/
fi

# Cleanup old backups
find $BACKUP_DIR -name "sonarqube_*" -mtime +$RETENTION_DAYS -delete

echo "Backup completed: $DATE"
```

#### Disaster Recovery Plan
```bash
#!/bin/bash
# restore-sonarqube.sh

BACKUP_FILE=$1
DATA_BACKUP=$2

if [ -z "$BACKUP_FILE" ] || [ -z "$DATA_BACKUP" ]; then
    echo "Usage: $0 <database_backup.sql.gz> <data_backup.tar.gz>"
    exit 1
fi

# Stop SonarQube
systemctl stop sonarqube

# Restore database
echo "Restoring database..."
dropdb sonarqube
createdb sonarqube
gunzip -c $BACKUP_FILE | psql sonarqube

# Restore data
echo "Restoring data directory..."
cd /opt/sonarqube
rm -rf data extensions
tar -xzf $DATA_BACKUP

# Fix permissions
chown -R sonarqube:sonarqube /opt/sonarqube

# Start SonarQube
systemctl start sonarqube

echo "Restore completed"
```

## Maintenance Procedures

### Regular Maintenance Tasks

#### Weekly Maintenance Script
```bash
#!/bin/bash
# weekly-maintenance.sh

echo "Starting weekly SonarQube maintenance - $(date)"

# 1. Database maintenance
echo "Running database maintenance..."
psql -d sonarqube -c "VACUUM ANALYZE;"
psql -d sonarqube -c "REINDEX DATABASE sonarqube;"

# 2. Clean old analysis data
echo "Cleaning old analysis data..."
curl -X POST -u admin:admin \
  "http://localhost:9000/api/projects/bulk_delete" \
  -d "analyzedBefore=$(date -d '1 year ago' +%Y-%m-%d)"

# 3. Update plugins
echo "Checking for plugin updates..."
curl -u admin:admin \
  "http://localhost:9000/api/plugins/updates"

# 4. System health check
echo "Running system health check..."
curl -f http://localhost:9000/api/system/health

# 5. Generate maintenance report
echo "Generating maintenance report..."
cat > /tmp/maintenance_report_$(date +%Y%m%d).txt << EOF
SonarQube Maintenance Report - $(date)
=====================================

Database Size: $(psql -d sonarqube -t -c "SELECT pg_size_pretty(pg_database_size('sonarqube'));")
Active Projects: $(curl -s -u admin:admin "http://localhost:9000/api/projects/search" | jq '.paging.total')
System Status: $(curl -s -u admin:admin "http://localhost:9000/api/system/status" | jq -r '.status')
JVM Memory: $(curl -s -u admin:admin "http://localhost:9000/api/system/info" | jq -r '.System."Heap Memory Usage"')

EOF

echo "Weekly maintenance completed"
```

### Performance Tuning Checklist

#### Monthly Performance Review
```bash
#!/bin/bash
# performance-review.sh

echo "SonarQube Performance Review - $(date)"
echo "====================================="

# 1. Check slow queries
echo "Top 10 slowest queries:"
psql -d sonarqube -c "
SELECT query, mean_time, calls, total_time 
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;"

# 2. Check database size growth
echo "Database size trend:"
psql -d sonarqube -c "
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
    pg_total_relation_size(schemaname||'.'||tablename) as bytes
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY bytes DESC
LIMIT 10;"

# 3. Check JVM performance
echo "JVM GC statistics:"
SONAR_PID=$(pgrep -f "sonar.application.app=SonarQube")
if [ -n "$SONAR_PID" ]; then
    jstat -gc $SONAR_PID
fi

# 4. Check response times
echo "API response time test:"
time curl -s -u admin:admin "http://localhost:9000/api/projects/search" > /dev/null

echo "Performance review completed"
```

This completes the comprehensive production best practices guide covering infrastructure, security, performance, monitoring, backup, and maintenance procedures for SonarQube.