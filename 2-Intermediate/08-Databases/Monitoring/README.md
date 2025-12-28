# Database Monitoring

Comprehensive guide to database monitoring, performance tracking, and alerting for production environments.

## Monitoring Strategy

### Key Performance Indicators (KPIs)
```yaml
availability_metrics:
  - uptime_percentage
  - connection_success_rate
  - failover_time

performance_metrics:
  - query_response_time
  - throughput_qps
  - connection_pool_usage
  - cache_hit_ratio

resource_metrics:
  - cpu_utilization
  - memory_usage
  - disk_io_utilization
  - network_throughput

business_metrics:
  - transaction_volume
  - error_rates
  - data_growth_rate
```

### Monitoring Levels
- **Infrastructure**: Hardware, OS, network
- **Database Engine**: MySQL, PostgreSQL, MongoDB specific metrics
- **Application**: Query performance, connection patterns
- **Business**: Transaction volumes, user activity

## MySQL Monitoring

### Performance Schema Queries
```sql
-- Top queries by execution time
SELECT 
  DIGEST_TEXT,
  COUNT_STAR,
  AVG_TIMER_WAIT/1000000000 AS avg_time_seconds,
  SUM_TIMER_WAIT/1000000000 AS total_time_seconds
FROM performance_schema.events_statements_summary_by_digest
ORDER BY SUM_TIMER_WAIT DESC
LIMIT 10;

-- Table I/O statistics
SELECT 
  OBJECT_SCHEMA,
  OBJECT_NAME,
  COUNT_READ,
  COUNT_WRITE,
  COUNT_FETCH,
  COUNT_INSERT,
  COUNT_UPDATE,
  COUNT_DELETE
FROM performance_schema.table_io_waits_summary_by_table
WHERE OBJECT_SCHEMA NOT IN ('mysql', 'performance_schema', 'information_schema')
ORDER BY COUNT_READ + COUNT_WRITE DESC;

-- Index usage statistics
SELECT 
  OBJECT_SCHEMA,
  OBJECT_NAME,
  INDEX_NAME,
  COUNT_FETCH,
  COUNT_INSERT,
  COUNT_UPDATE,
  COUNT_DELETE
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE OBJECT_SCHEMA = 'petclinic'
ORDER BY COUNT_FETCH DESC;

-- Connection statistics
SELECT 
  USER,
  HOST,
  CURRENT_CONNECTIONS,
  TOTAL_CONNECTIONS
FROM performance_schema.accounts
ORDER BY CURRENT_CONNECTIONS DESC;
```

### System Status Monitoring
```sql
-- Key status variables
SHOW STATUS LIKE 'Threads_connected';
SHOW STATUS LIKE 'Threads_running';
SHOW STATUS LIKE 'Questions';
SHOW STATUS LIKE 'Slow_queries';
SHOW STATUS LIKE 'Innodb_buffer_pool_read_requests';
SHOW STATUS LIKE 'Innodb_buffer_pool_reads';

-- Comprehensive status query
SELECT 
  'Connections' as metric,
  VARIABLE_VALUE as value
FROM performance_schema.global_status 
WHERE VARIABLE_NAME = 'Threads_connected'
UNION ALL
SELECT 
  'QPS' as metric,
  ROUND(VARIABLE_VALUE / (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Uptime'), 2) as value
FROM performance_schema.global_status 
WHERE VARIABLE_NAME = 'Questions'
UNION ALL
SELECT 
  'Buffer Pool Hit Ratio' as metric,
  ROUND((1 - (reads.VARIABLE_VALUE / requests.VARIABLE_VALUE)) * 100, 2) as value
FROM 
  (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_buffer_pool_reads') reads,
  (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_buffer_pool_read_requests') requests;
```

### Replication Monitoring
```sql
-- Master status
SHOW MASTER STATUS;

-- Slave status
SHOW SLAVE STATUS\G

-- Replication lag calculation
SELECT 
  CASE 
    WHEN Slave_IO_Running = 'Yes' AND Slave_SQL_Running = 'Yes' 
    THEN 'OK' 
    ELSE 'ERROR' 
  END AS Status,
  Seconds_Behind_Master AS Lag_Seconds,
  Master_Log_File,
  Read_Master_Log_Pos,
  Relay_Master_Log_File,
  Exec_Master_Log_Pos
FROM (SHOW SLAVE STATUS) AS slave_status;
```

## PostgreSQL Monitoring

### System Statistics
```sql
-- Database statistics
SELECT 
  datname,
  numbackends,
  xact_commit,
  xact_rollback,
  blks_read,
  blks_hit,
  ROUND((blks_hit::float / (blks_hit + blks_read) * 100), 2) AS cache_hit_ratio,
  tup_returned,
  tup_fetched,
  tup_inserted,
  tup_updated,
  tup_deleted
FROM pg_stat_database
WHERE datname NOT IN ('template0', 'template1', 'postgres');

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
  n_tup_del,
  n_live_tup,
  n_dead_tup,
  last_vacuum,
  last_autovacuum,
  last_analyze,
  last_autoanalyze
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
-- Enable pg_stat_statements extension
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Top queries by total time
SELECT 
  query,
  calls,
  total_time,
  mean_time,
  (total_time/sum(total_time) OVER()) * 100 AS percentage
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- Slow queries
SELECT 
  query,
  calls,
  total_time,
  mean_time,
  stddev_time,
  rows
FROM pg_stat_statements
WHERE mean_time > 1000  -- queries taking more than 1 second on average
ORDER BY mean_time DESC;

-- Current activity
SELECT 
  pid,
  usename,
  application_name,
  client_addr,
  state,
  query_start,
  now() - query_start AS duration,
  query
FROM pg_stat_activity
WHERE state = 'active'
  AND query NOT LIKE '%pg_stat_activity%'
ORDER BY duration DESC;
```

### Lock Monitoring
```sql
-- Current locks
SELECT 
  locktype,
  database,
  relation::regclass,
  page,
  tuple,
  pid,
  mode,
  granted
FROM pg_locks
WHERE NOT granted
ORDER BY pid;

-- Blocking queries
SELECT 
  blocked_locks.pid AS blocked_pid,
  blocked_activity.usename AS blocked_user,
  blocking_locks.pid AS blocking_pid,
  blocking_activity.usename AS blocking_user,
  blocked_activity.query AS blocked_statement,
  blocking_activity.query AS current_statement_in_blocking_process
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
  AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE
  AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
  AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
  AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
  AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
  AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
  AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
  AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
  AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
  AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.GRANTED;
```

## MongoDB Monitoring

### Database Statistics
```javascript
// Server status
db.runCommand({serverStatus: 1})

// Database statistics
db.stats()

// Collection statistics
db.collection.stats()

// Current operations
db.currentOp()

// Profiler data
db.system.profile.find().sort({ts: -1}).limit(5)

// Replication status
rs.status()

// Oplog information
db.oplog.rs.stats()
```

### Performance Monitoring
```javascript
// Connection statistics
db.runCommand({connPoolStats: 1})

// Index usage statistics
db.collection.aggregate([{$indexStats: {}}])

// Slow operations
db.system.profile.find({
  millis: {$gt: 1000}
}).sort({ts: -1})

// Lock statistics
db.runCommand({serverStatus: 1}).locks

// Memory usage
db.runCommand({serverStatus: 1}).mem

// Network statistics
db.runCommand({serverStatus: 1}).network
```

## Prometheus Integration

### MySQL Exporter Configuration
```yaml
# docker-compose.yml
version: '3.8'
services:
  mysql-exporter:
    image: prom/mysqld-exporter:latest
    ports:
      - "9104:9104"
    environment:
      - DATA_SOURCE_NAME=exporter:password@(mysql:3306)/
    command:
      - --collect.info_schema.processlist
      - --collect.info_schema.innodb_metrics
      - --collect.info_schema.tablestats
      - --collect.info_schema.tables
      - --collect.info_schema.userstats
      - --collect.engine_innodb_status
    depends_on:
      - mysql
```

### PostgreSQL Exporter Configuration
```yaml
# docker-compose.yml
version: '3.8'
services:
  postgres-exporter:
    image: prometheuscommunity/postgres-exporter:latest
    ports:
      - "9187:9187"
    environment:
      - DATA_SOURCE_NAME=postgresql://postgres:password@postgres:5432/postgres?sslmode=disable
    depends_on:
      - postgres
```

### MongoDB Exporter Configuration
```yaml
# docker-compose.yml
version: '3.8'
services:
  mongodb-exporter:
    image: percona/mongodb_exporter:latest
    ports:
      - "9216:9216"
    environment:
      - MONGODB_URI=mongodb://mongodb:27017
    command:
      - --mongodb.uri=mongodb://mongodb:27017
      - --mongodb.collstats-colls=petclinic.owners,petclinic.pets
    depends_on:
      - mongodb
```

## Grafana Dashboards

### MySQL Dashboard Configuration
```json
{
  "dashboard": {
    "title": "MySQL Performance Dashboard",
    "panels": [
      {
        "title": "QPS (Queries Per Second)",
        "type": "stat",
        "targets": [
          {
            "expr": "rate(mysql_global_status_questions[5m])",
            "legendFormat": "QPS"
          }
        ]
      },
      {
        "title": "Connection Usage",
        "type": "stat",
        "targets": [
          {
            "expr": "mysql_global_status_threads_connected / mysql_global_variables_max_connections * 100",
            "legendFormat": "Connection Usage %"
          }
        ]
      },
      {
        "title": "InnoDB Buffer Pool Hit Ratio",
        "type": "stat",
        "targets": [
          {
            "expr": "(mysql_global_status_innodb_buffer_pool_read_requests - mysql_global_status_innodb_buffer_pool_reads) / mysql_global_status_innodb_buffer_pool_read_requests * 100",
            "legendFormat": "Hit Ratio %"
          }
        ]
      }
    ]
  }
}
```

### PostgreSQL Dashboard Queries
```promql
# Connection usage
pg_stat_database_numbackends / pg_settings_max_connections * 100

# Cache hit ratio
(pg_stat_database_blks_hit / (pg_stat_database_blks_hit + pg_stat_database_blks_read)) * 100

# Transaction rate
rate(pg_stat_database_xact_commit[5m]) + rate(pg_stat_database_xact_rollback[5m])

# Slow queries
pg_stat_statements_mean_time_seconds > 1
```

## Alerting Rules

### Prometheus Alerting Rules
```yaml
# alerts.yml
groups:
- name: database.rules
  rules:
  - alert: DatabaseDown
    expr: up{job=~"mysql|postgres|mongodb"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Database {{ $labels.instance }} is down"
      description: "Database has been down for more than 1 minute"

  - alert: HighConnectionUsage
    expr: mysql_global_status_threads_connected / mysql_global_variables_max_connections * 100 > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High connection usage on {{ $labels.instance }}"
      description: "Connection usage is {{ $value }}%"

  - alert: SlowQueries
    expr: rate(mysql_global_status_slow_queries[5m]) > 0.1
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "High number of slow queries on {{ $labels.instance }}"
      description: "Slow query rate is {{ $value }} per second"

  - alert: ReplicationLag
    expr: mysql_slave_lag_seconds > 30
    for: 1m
    labels:
      severity: warning
    annotations:
      summary: "MySQL replication lag on {{ $labels.instance }}"
      description: "Replication lag is {{ $value }} seconds"

  - alert: LowBufferPoolHitRatio
    expr: (mysql_global_status_innodb_buffer_pool_read_requests - mysql_global_status_innodb_buffer_pool_reads) / mysql_global_status_innodb_buffer_pool_read_requests * 100 < 95
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Low InnoDB buffer pool hit ratio on {{ $labels.instance }}"
      description: "Buffer pool hit ratio is {{ $value }}%"
```

## Custom Monitoring Scripts

### Health Check Script
```bash
#!/bin/bash
# db_health_check.sh

DB_HOST="localhost"
DB_USER="monitor"
DB_PASS="monitor_password"
THRESHOLD_CONNECTIONS=80
THRESHOLD_SLOW_QUERIES=10

# Check MySQL connectivity
if ! mysql -h $DB_HOST -u $DB_USER -p$DB_PASS -e "SELECT 1" > /dev/null 2>&1; then
    echo "CRITICAL: Cannot connect to MySQL"
    exit 2
fi

# Check connection usage
CONNECTIONS=$(mysql -h $DB_HOST -u $DB_USER -p$DB_PASS -e "SHOW STATUS LIKE 'Threads_connected'" | awk 'NR==2 {print $2}')
MAX_CONNECTIONS=$(mysql -h $DB_HOST -u $DB_USER -p$DB_PASS -e "SHOW VARIABLES LIKE 'max_connections'" | awk 'NR==2 {print $2}')
CONNECTION_USAGE=$((CONNECTIONS * 100 / MAX_CONNECTIONS))

if [ $CONNECTION_USAGE -gt $THRESHOLD_CONNECTIONS ]; then
    echo "WARNING: High connection usage: ${CONNECTION_USAGE}%"
    exit 1
fi

# Check slow queries
SLOW_QUERIES=$(mysql -h $DB_HOST -u $DB_USER -p$DB_PASS -e "SHOW STATUS LIKE 'Slow_queries'" | awk 'NR==2 {print $2}')
if [ $SLOW_QUERIES -gt $THRESHOLD_SLOW_QUERIES ]; then
    echo "WARNING: High number of slow queries: $SLOW_QUERIES"
    exit 1
fi

echo "OK: Database health check passed"
exit 0
```

### Performance Monitoring Script
```python
#!/usr/bin/env python3
# db_performance_monitor.py

import mysql.connector
import time
import json
from datetime import datetime

def collect_mysql_metrics():
    config = {
        'user': 'monitor',
        'password': 'monitor_password',
        'host': 'localhost',
        'database': 'performance_schema'
    }
    
    try:
        conn = mysql.connector.connect(**config)
        cursor = conn.cursor()
        
        metrics = {}
        
        # QPS calculation
        cursor.execute("SHOW STATUS LIKE 'Questions'")
        questions = int(cursor.fetchone()[1])
        
        cursor.execute("SHOW STATUS LIKE 'Uptime'")
        uptime = int(cursor.fetchone()[1])
        
        metrics['qps'] = round(questions / uptime, 2)
        
        # Connection metrics
        cursor.execute("SHOW STATUS LIKE 'Threads_connected'")
        metrics['connections'] = int(cursor.fetchone()[1])
        
        cursor.execute("SHOW VARIABLES LIKE 'max_connections'")
        max_connections = int(cursor.fetchone()[1])
        metrics['connection_usage_percent'] = round((metrics['connections'] / max_connections) * 100, 2)
        
        # Buffer pool hit ratio
        cursor.execute("SHOW STATUS LIKE 'Innodb_buffer_pool_read_requests'")
        read_requests = int(cursor.fetchone()[1])
        
        cursor.execute("SHOW STATUS LIKE 'Innodb_buffer_pool_reads'")
        reads = int(cursor.fetchone()[1])
        
        if read_requests > 0:
            metrics['buffer_pool_hit_ratio'] = round(((read_requests - reads) / read_requests) * 100, 2)
        else:
            metrics['buffer_pool_hit_ratio'] = 0
        
        # Slow queries
        cursor.execute("SHOW STATUS LIKE 'Slow_queries'")
        metrics['slow_queries'] = int(cursor.fetchone()[1])
        
        metrics['timestamp'] = datetime.now().isoformat()
        
        return metrics
        
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        return None
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    metrics = collect_mysql_metrics()
    if metrics:
        print(json.dumps(metrics, indent=2))
```

## Log Analysis

### MySQL Error Log Analysis
```bash
#!/bin/bash
# mysql_log_analyzer.sh

LOG_FILE="/var/log/mysql/error.log"
ALERT_KEYWORDS="ERROR|CRITICAL|Fatal|Aborted"

# Check for recent errors
echo "Recent errors in MySQL log:"
tail -1000 $LOG_FILE | grep -E "$ALERT_KEYWORDS" | tail -10

# Count error types
echo -e "\nError summary:"
tail -10000 $LOG_FILE | grep -E "$ALERT_KEYWORDS" | awk '{print $3}' | sort | uniq -c | sort -nr

# Check for connection issues
echo -e "\nConnection issues:"
tail -1000 $LOG_FILE | grep -i "connection" | tail -5
```

### Slow Query Log Analysis
```bash
#!/bin/bash
# slow_query_analyzer.sh

SLOW_LOG="/var/log/mysql/slow.log"

# Use mysqldumpslow for analysis
echo "Top 10 slowest queries:"
mysqldumpslow -s t -t 10 $SLOW_LOG

echo -e "\nTop 10 most frequent slow queries:"
mysqldumpslow -s c -t 10 $SLOW_LOG

echo -e "\nTop 10 queries by average execution time:"
mysqldumpslow -s at -t 10 $SLOW_LOG
```

This comprehensive monitoring guide provides complete observability for database systems in production environments.