# Database Best Practices

Comprehensive guide to database best practices for performance, security, reliability, and maintainability in production environments.

## General Database Principles

### Design Principles
- **Normalization**: Eliminate data redundancy while maintaining performance
- **Consistency**: Maintain ACID properties where required
- **Scalability**: Design for horizontal and vertical scaling
- **Performance**: Optimize for read/write patterns
- **Security**: Implement defense in depth
- **Monitoring**: Comprehensive observability and alerting

### Data Modeling Best Practices
```sql
-- Use appropriate data types
CREATE TABLE users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  balance DECIMAL(10,2) DEFAULT 0.00
);

-- Proper indexing strategy
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_active_created ON users(is_active, created_at);
```

## Performance Optimization

### Query Optimization
```sql
-- Use EXPLAIN to analyze queries
EXPLAIN SELECT * FROM users WHERE email = 'user@example.com';

-- Avoid SELECT *
SELECT id, email, created_at FROM users WHERE is_active = TRUE;

-- Use appropriate WHERE clauses
SELECT * FROM orders WHERE created_at >= '2024-01-01' AND status = 'completed';

-- Limit result sets
SELECT * FROM users ORDER BY created_at DESC LIMIT 100;

-- Use JOINs efficiently
SELECT u.email, p.name 
FROM users u 
INNER JOIN profiles p ON u.id = p.user_id 
WHERE u.is_active = TRUE;
```

### Indexing Strategy
```sql
-- Primary key optimization
CREATE TABLE orders (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_created (user_id, created_at),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Composite indexes for common queries
CREATE INDEX idx_orders_status_date ON orders(status, created_at);

-- Partial indexes (PostgreSQL)
CREATE INDEX idx_active_users ON users(email) WHERE is_active = TRUE;

-- Covering indexes
CREATE INDEX idx_user_profile_covering ON users(id, email, created_at);
```

### Connection Management
```yaml
# Connection pool configuration
database:
  pool:
    initial_size: 5
    max_size: 20
    min_idle: 2
    max_idle: 10
    max_wait: 30000
    validation_query: "SELECT 1"
    test_on_borrow: true
    test_while_idle: true
```

## Security Best Practices

### Access Control
```sql
-- Principle of least privilege
CREATE USER 'app_read'@'%' IDENTIFIED BY 'secure_password';
GRANT SELECT ON petclinic.* TO 'app_read'@'%';

CREATE USER 'app_write'@'%' IDENTIFIED BY 'secure_password';
GRANT SELECT, INSERT, UPDATE ON petclinic.* TO 'app_write'@'%';

-- Role-based access control
CREATE ROLE 'petclinic_reader';
GRANT SELECT ON petclinic.* TO 'petclinic_reader';

CREATE ROLE 'petclinic_writer';
GRANT SELECT, INSERT, UPDATE, DELETE ON petclinic.* TO 'petclinic_writer';

-- Grant roles to users
GRANT 'petclinic_reader' TO 'readonly_user'@'%';
GRANT 'petclinic_writer' TO 'app_user'@'%';
```

### Data Protection
```sql
-- Encrypt sensitive data
CREATE TABLE users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  ssn VARBINARY(255), -- Encrypted field
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Use parameterized queries (prevent SQL injection)
-- Good (parameterized)
SELECT * FROM users WHERE email = ?

-- Bad (vulnerable to injection)
SELECT * FROM users WHERE email = '" + userInput + "'
```

### Network Security
```bash
# SSL/TLS configuration
[mysqld]
ssl-ca=/etc/mysql/ssl/ca.pem
ssl-cert=/etc/mysql/ssl/server-cert.pem
ssl-key=/etc/mysql/ssl/server-key.pem
require_secure_transport=ON

# Firewall rules
sudo ufw allow from 192.168.1.0/24 to any port 3306
sudo ufw deny 3306

# Bind to specific interfaces
bind-address = 10.0.1.100
```

## Backup and Recovery

### Backup Strategy
```bash
# Full backup schedule
0 2 * * * /usr/local/bin/full_backup.sh

# Incremental backup schedule
0 */6 * * * /usr/local/bin/incremental_backup.sh

# Point-in-time recovery setup
[mysqld]
log-bin=mysql-bin
binlog-format=ROW
expire_logs_days=7
```

### Backup Scripts
```bash
#!/bin/bash
# full_backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/mysql"
DB_NAME="petclinic"

# Create backup directory
mkdir -p $BACKUP_DIR

# Full backup with compression
mysqldump --single-transaction \
  --routines \
  --triggers \
  --all-databases | gzip > $BACKUP_DIR/full_backup_$DATE.sql.gz

# Verify backup
if [ $? -eq 0 ]; then
  echo "Backup completed successfully: $BACKUP_DIR/full_backup_$DATE.sql.gz"

# Remove backups older than 30 days
  find $BACKUP_DIR -name "full_backup_*.sql.gz" -mtime +30 -delete
else
  echo "Backup failed!" >&2
  exit 1
fi
```

### Recovery Procedures
```bash
# Point-in-time recovery
# 1. Restore from last full backup
gunzip < /backup/mysql/full_backup_20240101_020000.sql.gz | mysql

# 2. Apply binary logs up to specific point
mysqlbinlog --start-datetime="2024-01-01 02:00:00" \
  --stop-datetime="2024-01-01 14:30:00" \
  /var/lib/mysql/mysql-bin.000001 | mysql

# 3. Verify recovery
mysql -e "SELECT COUNT(*) FROM petclinic.owners;"
```

## High Availability

### Replication Setup
```sql
-- Master configuration
[mysqld]
server-id=1
log-bin=mysql-bin
binlog-format=ROW
gtid-mode=ON
enforce-gtid-consistency=ON

-- Create replication user
CREATE USER 'replicator'@'%' IDENTIFIED BY 'replication_password';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';
FLUSH PRIVILEGES;

-- Slave configuration
[mysqld]
server-id=2
relay-log=mysql-relay-bin
read-only=ON
gtid-mode=ON
enforce-gtid-consistency=ON
```

### Load Balancing
```yaml
# HAProxy configuration for database load balancing
global
  daemon

defaults
  mode tcp
  timeout connect 5000ms
  timeout client 50000ms
  timeout server 50000ms

frontend mysql_frontend
  bind *:3306
  default_backend mysql_backend

backend mysql_backend
  balance roundrobin
  option mysql-check user haproxy_check
  server mysql1 10.0.1.10:3306 check
  server mysql2 10.0.1.11:3306 check backup
```

### Failover Procedures
```bash
#!/bin/bash
# failover.sh - Automated failover script

MASTER_HOST="10.0.1.10"
SLAVE_HOST="10.0.1.11"

# Check master health
if ! mysql -h $MASTER_HOST -e "SELECT 1" > /dev/null 2>&1; then
  echo "Master is down, initiating failover..."

# Promote slave to master
  mysql -h $SLAVE_HOST -e "STOP SLAVE; RESET SLAVE ALL; SET GLOBAL read_only = OFF;"

# Update application configuration
  sed -i "s/$MASTER_HOST/$SLAVE_HOST/g" /etc/app/database.conf

# Restart application
  systemctl restart myapp

echo "Failover completed"
fi
```

## Monitoring and Alerting

### Key Metrics
```sql
-- Connection monitoring
SHOW STATUS LIKE 'Threads_connected';
SHOW STATUS LIKE 'Max_used_connections';

-- Query performance
SHOW STATUS LIKE 'Slow_queries';
SHOW STATUS LIKE 'Questions';

-- InnoDB metrics
SHOW STATUS LIKE 'Innodb_buffer_pool_read_requests';
SHOW STATUS LIKE 'Innodb_buffer_pool_reads';

-- Replication monitoring
SHOW SLAVE STATUS\G
```

### Monitoring Queries
```sql
-- Long-running queries
SELECT 
  id,
  user,
  host,
  db,
  command,
  time,
  state,
  info
FROM information_schema.PROCESSLIST
WHERE time > 300
ORDER BY time DESC;

-- Table sizes
SELECT 
  table_schema,
  table_name,
  ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE table_schema NOT IN ('information_schema', 'mysql', 'performance_schema')
ORDER BY (data_length + index_length) DESC;

-- Index usage
SELECT 
  object_schema,
  object_name,
  index_name,
  count_read,
  count_write,
  count_fetch,
  count_insert,
  count_update,
  count_delete
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE object_schema NOT IN ('mysql', 'performance_schema', 'information_schema')
ORDER BY count_read DESC;
```

### Alerting Configuration
```yaml
# Prometheus alerting rules
groups:
- name: mysql
  rules:
  - alert: MySQLDown
    expr: mysql_up == 0
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "MySQL instance is down"

- alert: MySQLSlowQueries
    expr: rate(mysql_global_status_slow_queries[5m]) > 0.1
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "High number of slow queries"

- alert: MySQLReplicationLag
    expr: mysql_slave_lag_seconds > 30
    for: 1m
    labels:
      severity: warning
    annotations:
      summary: "MySQL replication lag is high"
```

## Capacity Planning

### Growth Monitoring
```sql
-- Daily growth tracking
CREATE TABLE db_growth_stats (
  date DATE PRIMARY KEY,
  total_size_mb DECIMAL(10,2),
  table_count INT,
  row_count BIGINT,
  index_size_mb DECIMAL(10,2)
);

-- Insert daily stats
INSERT INTO db_growth_stats (date, total_size_mb, table_count, row_count, index_size_mb)
SELECT 
  CURDATE(),
  ROUND(SUM(data_length + index_length) / 1024 / 1024, 2),
  COUNT(*),
  SUM(table_rows),
  ROUND(SUM(index_length) / 1024 / 1024, 2)
FROM information_schema.TABLES
WHERE table_schema = 'petclinic';
```

### Resource Planning
```bash
# Calculate required resources
# Rule of thumb: Buffer pool = 70-80% of available RAM for InnoDB
# Connections: 100-200 per CPU core
# Storage: Plan for 3x current size for 2 years

# Example calculation for 1TB database
RAM_REQUIRED=$((1024 * 1024 * 0.8))  # 80% of 1TB for buffer pool
CPU_CORES=8  # For 800-1600 connections
STORAGE_REQUIRED=$((1024 * 3))  # 3TB for growth
```

## Development Best Practices

### Schema Versioning
```sql
-- Migration tracking table
CREATE TABLE schema_migrations (
  version VARCHAR(50) PRIMARY KEY,
  applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  description TEXT
);

-- Example migration
-- V001__create_users_table.sql
CREATE TABLE users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO schema_migrations (version, description) 
VALUES ('V001', 'Create users table');
```

### Testing Strategies
```sql
-- Test data setup
INSERT INTO users (email) VALUES 
  ('test1@example.com'),
  ('test2@example.com'),
  ('test3@example.com');

-- Performance testing
-- Load test with realistic data volumes
-- Test with production-like data distribution
-- Validate query performance under load

-- Backup/restore testing
-- Regular restore tests to verify backup integrity
-- Test point-in-time recovery procedures
-- Validate failover scenarios
```

### Code Review Guidelines
```yaml
database_changes:
  required_reviews: 2
  checklist:
    - Schema changes are backward compatible
    - Indexes are properly defined
    - Migration scripts are tested
    - Performance impact is assessed
    - Security implications are reviewed
    - Backup strategy is updated if needed
```

## Compliance and Auditing

### Audit Logging
```sql
-- Enable audit logging (MySQL Enterprise)
INSTALL PLUGIN audit_log SONAME 'audit_log.so';
SET GLOBAL audit_log_policy = ALL;
SET GLOBAL audit_log_format = JSON;

-- Custom audit table
CREATE TABLE audit_log (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user VARCHAR(100),
  action VARCHAR(50),
  table_name VARCHAR(100),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  old_values JSON,
  new_values JSON
);
```

### Data Retention
```sql
-- Automated data archival
CREATE EVENT archive_old_data
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
  -- Archive data older than 7 years
  INSERT INTO archived_orders 
  SELECT * FROM orders 
  WHERE created_at < DATE_SUB(NOW(), INTERVAL 7 YEAR);

DELETE FROM orders 
  WHERE created_at < DATE_SUB(NOW(), INTERVAL 7 YEAR);
END;
```

### GDPR Compliance
```sql
-- Data anonymization
UPDATE users 
SET 
  email = CONCAT('user_', id, '@anonymized.com'),
  first_name = 'Anonymous',
  last_name = 'User',
  phone = NULL,
  address = NULL
WHERE gdpr_delete_requested = TRUE 
  AND gdpr_request_date < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- Right to be forgotten
DELETE FROM user_activities WHERE user_id IN (
  SELECT id FROM users WHERE gdpr_delete_requested = TRUE
);
```

This comprehensive best practices guide ensures robust, secure, and maintainable database operations in production environments.