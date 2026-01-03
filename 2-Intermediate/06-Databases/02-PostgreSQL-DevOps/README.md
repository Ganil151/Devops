# PostgreSQL Administration

Complete guide to PostgreSQL installation, configuration, and management for production environments.

## Installation

### RHEL/CentOS/Amazon Linux
```bash
# Install PostgreSQL repository
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Install PostgreSQL 15
sudo yum install -y postgresql15-server postgresql15

# Initialize database
sudo /usr/pgsql-15/bin/postgresql-15-setup initdb

# Start and enable service
sudo systemctl start postgresql-15
sudo systemctl enable postgresql-15
```

### Ubuntu/Debian
```bash
# Add PostgreSQL repository
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

# Install PostgreSQL
sudo apt update
sudo apt install -y postgresql-15 postgresql-client-15

# Service is automatically started
sudo systemctl status postgresql
```

### Docker Installation
```bash
# Run PostgreSQL container
docker run -d \
  --name postgres-petclinic \
  -e POSTGRES_DB=petclinic \
  -e POSTGRES_USER=petclinic \
  -e POSTGRES_PASSWORD=petclinic \
  -p 5432:5432 \
  -v postgres-data:/var/lib/postgresql/data \
  postgres:15

# Connect to container
docker exec -it postgres-petclinic psql -U petclinic -d petclinic
```

## Configuration

### Main Configuration Files
```bash
# PostgreSQL configuration
/var/lib/pgsql/15/data/postgresql.conf

# Client authentication
/var/lib/pgsql/15/data/pg_hba.conf

# Recovery configuration
/var/lib/pgsql/15/data/recovery.conf
```

### Key Configuration Parameters
```bash
# postgresql.conf
listen_addresses = '*'
port = 5432
max_connections = 200
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 64MB
wal_level = replica
max_wal_senders = 3
archive_mode = on
archive_command = 'cp %p /backup/archive/%f'
log_destination = 'stderr'
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_min_duration_statement = 1000
```

### Authentication Configuration
```bash
# pg_hba.conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# Local connections
local   all             postgres                                peer
local   all             all                                     md5

# IPv4 local connections
host    all             all             127.0.0.1/32            md5

# IPv6 local connections
host    all             all             ::1/128                 md5

# Remote connections
host    all             all             0.0.0.0/0               md5
```

## Database Management

### Connection and Basic Operations
```bash
# Connect as postgres user
sudo -u postgres psql

# Connect to specific database
psql -h localhost -U petclinic -d petclinic

# Connect with password prompt
psql -h localhost -U petclinic -d petclinic -W

# Execute command without entering interactive mode
psql -U postgres -c "SELECT version();"

# Execute commands from file
psql -U postgres -f script.sql

# List databases
psql -U postgres -l
```

### Database Operations
```sql
-- List databases
\l

-- Create database
CREATE DATABASE petclinic
  WITH ENCODING 'UTF8'
       LC_COLLATE='en_US.UTF-8'
       LC_CTYPE='en_US.UTF-8'
       TEMPLATE=template0;

-- Connect to database
\c petclinic

-- Drop database
DROP DATABASE petclinic;

-- Show current database
SELECT current_database();

-- Database size
SELECT pg_size_pretty(pg_database_size('petclinic'));

-- All database sizes
SELECT 
  datname AS database_name,
  pg_size_pretty(pg_database_size(datname)) AS size
FROM pg_database
WHERE datistemplate = false
ORDER BY pg_database_size(datname) DESC;
```

### Table Management
```sql
-- List tables
\dt

-- Describe table
\d table_name

-- Create table
CREATE TABLE owners (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(30) NOT NULL,
  last_name VARCHAR(30) NOT NULL,
  address VARCHAR(255),
  city VARCHAR(80),
  telephone VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index
CREATE INDEX idx_owners_last_name ON owners(last_name);

-- Table size
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size,
  pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS index_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

## User Management

### User Operations
```sql
-- List users
\du

-- Create user
CREATE USER petclinic WITH PASSWORD 'petclinic';

-- Create user with options
CREATE USER petclinic WITH 
  PASSWORD 'petclinic'
  CREATEDB
  CREATEROLE
  LOGIN;

-- Alter user
ALTER USER petclinic WITH PASSWORD 'new_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE petclinic TO petclinic;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO petclinic;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO petclinic;

-- Grant specific privileges
GRANT SELECT, INSERT, UPDATE, DELETE ON owners TO petclinic;

-- Revoke privileges
REVOKE ALL PRIVILEGES ON DATABASE petclinic FROM petclinic;

-- Drop user
DROP USER petclinic;

-- Show user privileges
SELECT 
  grantee,
  table_catalog,
  table_schema,
  table_name,
  privilege_type
FROM information_schema.table_privileges
WHERE grantee = 'petclinic';
```

## Backup and Restore

### Backup Operations
```bash
# Backup single database
pg_dump -U postgres -h localhost petclinic > petclinic_backup.sql

# Backup with compression
pg_dump -U postgres -h localhost -Fc petclinic > petclinic_backup.dump

# Backup all databases
pg_dumpall -U postgres > all_databases.sql

# Backup specific table
pg_dump -U postgres -h localhost -t owners petclinic > owners_backup.sql

# Backup schema only
pg_dump -U postgres -h localhost -s petclinic > schema_only.sql

# Backup data only
pg_dump -U postgres -h localhost -a petclinic > data_only.sql

# Backup with custom format
pg_dump -U postgres -h localhost -Fc -f petclinic.dump petclinic

# Backup with parallel jobs
pg_dump -U postgres -h localhost -Fd -j 4 -f petclinic_dir petclinic
```

### Restore Operations
```bash
# Restore from SQL file
psql -U postgres -h localhost petclinic < petclinic_backup.sql

# Restore from custom format
pg_restore -U postgres -h localhost -d petclinic petclinic_backup.dump

# Restore with create database
pg_restore -U postgres -h localhost -C -d postgres petclinic_backup.dump

# Restore specific table
pg_restore -U postgres -h localhost -d petclinic -t owners petclinic_backup.dump

# Restore with parallel jobs
pg_restore -U postgres -h localhost -d petclinic -j 4 petclinic_dir

# Restore all databases
psql -U postgres < all_databases.sql
```

## Performance Monitoring

### System Information
```sql
-- PostgreSQL version
SELECT version();

-- Current connections
SELECT count(*) FROM pg_stat_activity;

-- Database statistics
SELECT 
  datname,
  numbackends,
  xact_commit,
  xact_rollback,
  blks_read,
  blks_hit,
  tup_returned,
  tup_fetched,
  tup_inserted,
  tup_updated,
  tup_deleted
FROM pg_stat_database
WHERE datname = 'petclinic';

-- Table statistics
SELECT 
  schemaname,
  tablename,
  seq_scan,
  seq_tup_read,
  idx_scan,
  idx_tup_fetch,
  n_tup_ins,
  n_tup_upd,
  n_tup_del
FROM pg_stat_user_tables
ORDER BY seq_scan DESC;

-- Index usage
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

### Query Performance
```sql
-- Enable query statistics (requires pg_stat_statements extension)
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Top queries by total time
SELECT 
  query,
  calls,
  total_time,
  mean_time,
  rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- Slow queries
SELECT 
  query,
  calls,
  total_time,
  mean_time,
  (total_time/calls) AS avg_time_ms
FROM pg_stat_statements
WHERE calls > 100
ORDER BY mean_time DESC
LIMIT 10;

-- Current activity
SELECT 
  pid,
  usename,
  application_name,
  client_addr,
  state,
  query_start,
  query
FROM pg_stat_activity
WHERE state = 'active'
ORDER BY query_start;
```

## Replication Setup

### Master Configuration
```bash
# postgresql.conf
wal_level = replica
max_wal_senders = 3
wal_keep_segments = 32
archive_mode = on
archive_command = 'cp %p /backup/archive/%f'

# pg_hba.conf
host replication replicator 192.168.1.0/24 md5
```

### Create Replication User
```sql
CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replicator_password';
```

### Slave Setup
```bash
# Stop PostgreSQL on slave
sudo systemctl stop postgresql-15

# Remove data directory
sudo rm -rf /var/lib/pgsql/15/data/*

# Create base backup
pg_basebackup -h master_ip -D /var/lib/pgsql/15/data -U replicator -P -v -R -W

# Start PostgreSQL on slave
sudo systemctl start postgresql-15
```

### Monitor Replication
```sql
-- On master
SELECT 
  client_addr,
  state,
  sent_lsn,
  write_lsn,
  flush_lsn,
  replay_lsn,
  sync_state
FROM pg_stat_replication;

-- On slave
SELECT 
  pg_is_in_recovery(),
  pg_last_wal_receive_lsn(),
  pg_last_wal_replay_lsn(),
  pg_last_xact_replay_timestamp();
```

## Security Configuration

### SSL Configuration
```bash
# Generate SSL certificates
openssl req -new -x509 -days 365 -nodes -text -out server.crt -keyout server.key -subj "/CN=postgres.example.com"

# Set permissions
chmod 600 server.key
chown postgres:postgres server.key server.crt

# postgresql.conf
ssl = on
ssl_cert_file = 'server.crt'
ssl_key_file = 'server.key'
```

### Authentication Methods
```bash
# pg_hba.conf examples

# Trust (no password) - development only
local all all trust

# MD5 password authentication
host all all 192.168.1.0/24 md5

# SCRAM-SHA-256 (recommended)
host all all 192.168.1.0/24 scram-sha-256

# Certificate authentication
hostssl all all 192.168.1.0/24 cert

# LDAP authentication
host all all 192.168.1.0/24 ldap ldapserver=ldap.example.com ldapbasedn="dc=example,dc=com"
```

## Maintenance Operations

### VACUUM and ANALYZE
```sql
-- Manual vacuum
VACUUM VERBOSE owners;

-- Full vacuum (locks table)
VACUUM FULL owners;

-- Analyze statistics
ANALYZE owners;

-- Vacuum and analyze
VACUUM ANALYZE owners;

-- Auto-vacuum settings
SHOW autovacuum;
SELECT name, setting FROM pg_settings WHERE name LIKE 'autovacuum%';
```

### Index Maintenance
```sql
-- Rebuild index
REINDEX INDEX idx_owners_last_name;

-- Rebuild all indexes on table
REINDEX TABLE owners;

-- Rebuild all indexes in database
REINDEX DATABASE petclinic;

-- Find unused indexes
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan,
  pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;
```

## Troubleshooting

### Common Issues
```bash
# Check PostgreSQL status
sudo systemctl status postgresql-15

# Check logs
sudo tail -f /var/lib/pgsql/15/data/log/postgresql-*.log

# Check connections
netstat -tulpn | grep 5432

# Test connection
psql -h localhost -U postgres -c "SELECT 1;"
```

### Performance Issues
```sql
-- Check for long-running queries
SELECT 
  pid,
  now() - pg_stat_activity.query_start AS duration,
  query
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes';

-- Kill long-running query
SELECT pg_terminate_backend(pid);

-- Check locks
SELECT 
  locktype,
  database,
  relation,
  page,
  tuple,
  pid,
  mode,
  granted
FROM pg_locks
WHERE NOT granted;
```

This comprehensive PostgreSQL guide covers all essential administration tasks for production environments.