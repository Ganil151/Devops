# Enterprise GitLab Administration

## Enterprise Architecture Overview

### GitLab Reference Architecture

#### Small Enterprise (1,000 users)
```yaml
Architecture Components:
  - 2x Application Servers (4 vCPU, 16GB RAM)
  - 1x Database Server (4 vCPU, 16GB RAM)
  - 1x Redis Server (2 vCPU, 8GB RAM)
  - 1x Load Balancer (2 vCPU, 4GB RAM)
  - Shared Storage (NFS/GlusterFS)

Estimated Performance:
  - Concurrent Users: 1,000
  - Git Operations: 2,000/hour
  - CI/CD Jobs: 500/hour
```

#### Medium Enterprise (5,000 users)
```yaml
Architecture Components:
  - 3x Application Servers (8 vCPU, 32GB RAM)
  - 2x Database Servers (HA setup, 8 vCPU, 32GB RAM)
  - 2x Redis Servers (Sentinel, 4 vCPU, 16GB RAM)
  - 2x Load Balancers (HA, 4 vCPU, 8GB RAM)
  - Distributed Storage (Ceph/GlusterFS)
  - 5x GitLab Runners (16 vCPU, 32GB RAM)

Estimated Performance:
  - Concurrent Users: 5,000
  - Git Operations: 10,000/hour
  - CI/CD Jobs: 2,500/hour
```

#### Large Enterprise (25,000+ users)
```yaml
Architecture Components:
  - 6x Application Servers (16 vCPU, 64GB RAM)
  - 3x Database Servers (Cluster, 16 vCPU, 64GB RAM)
  - 3x Redis Servers (Cluster, 8 vCPU, 32GB RAM)
  - 3x Load Balancers (HA, 8 vCPU, 16GB RAM)
  - Object Storage (S3/MinIO)
  - 20x GitLab Runners (32 vCPU, 64GB RAM)
  - Monitoring Stack (Prometheus/Grafana)

Estimated Performance:
  - Concurrent Users: 25,000+
  - Git Operations: 50,000/hour
  - CI/CD Jobs: 12,500/hour
```

## Multi-Node Deployment

### 1. Application Server Configuration
```ruby
# /etc/gitlab/gitlab.rb - Application Server
external_url 'https://gitlab.company.com'

# Disable services not needed on app servers
postgresql['enable'] = false
redis['enable'] = false
nginx['enable'] = false
prometheus['enable'] = false
grafana['enable'] = false
alertmanager['enable'] = false

# Database configuration
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'unicode'
gitlab_rails['db_host'] = 'postgres.internal.company.com'
gitlab_rails['db_port'] = 5432
gitlab_rails['db_database'] = 'gitlabhq_production'
gitlab_rails['db_username'] = 'gitlab'
gitlab_rails['db_password'] = 'secure_password'

# Redis configuration
gitlab_rails['redis_host'] = 'redis.internal.company.com'
gitlab_rails['redis_port'] = 6379
gitlab_rails['redis_password'] = 'redis_password'

# Object storage configuration
gitlab_rails['object_store']['enabled'] = true
gitlab_rails['object_store']['proxy_download'] = true
gitlab_rails['object_store']['connection'] = {
  'provider' => 'AWS',
  'region' => 'us-east-1',
  'aws_access_key_id' => 'ACCESS_KEY',
  'aws_secret_access_key' => 'SECRET_KEY'
}

# Gitaly configuration
git_data_dirs({
  "default" => {
    "gitaly_address" => "tcp://gitaly.internal.company.com:8075"
  }
})

# Application server specific settings
gitlab_rails['application_settings_cache_seconds'] = 60
unicorn['worker_processes'] = 16
unicorn['worker_timeout'] = 60
sidekiq['max_concurrency'] = 25
```

### 2. Database Server Configuration
```ruby
# /etc/gitlab/gitlab.rb - Database Server
external_url 'https://gitlab.company.com'

# Disable all services except PostgreSQL
gitlab_rails['enable'] = false
unicorn['enable'] = false
sidekiq['enable'] = false
nginx['enable'] = false
redis['enable'] = false
prometheus['enable'] = false
grafana['enable'] = false
gitaly['enable'] = false

# PostgreSQL configuration
postgresql['enable'] = true
postgresql['listen_address'] = '0.0.0.0'
postgresql['port'] = 5432
postgresql['max_connections'] = 200
postgresql['shared_buffers'] = "8GB"
postgresql['effective_cache_size'] = "24GB"
postgresql['work_mem'] = "64MB"
postgresql['maintenance_work_mem'] = "2GB"
postgresql['checkpoint_completion_target'] = 0.9
postgresql['wal_buffers'] = "16MB"
postgresql['default_statistics_target'] = 100

# Replication configuration (for HA)
postgresql['sql_replication_user'] = 'gitlab_replicator'
postgresql['sql_replication_password'] = 'replication_password'
postgresql['wal_level'] = 'replica'
postgresql['max_wal_senders'] = 10
postgresql['wal_keep_segments'] = 50
postgresql['hot_standby'] = 'on'
```

### 3. Load Balancer Configuration (HAProxy)
```bash
# /etc/haproxy/haproxy.cfg
global
    daemon
    user haproxy
    group haproxy
    maxconn 4096
    log stdout local0

defaults
    mode http
    log global
    option httplog
    option dontlognull
    option redispatch
    retries 3
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend gitlab_frontend
    bind *:80
    bind *:443 ssl crt /etc/ssl/certs/gitlab.pem
    redirect scheme https if !{ ssl_fc }
    default_backend gitlab_backend

backend gitlab_backend
    balance roundrobin
    option httpchk GET /users/sign_in
    http-check expect status 200
    server gitlab1 10.0.1.10:80 check
    server gitlab2 10.0.1.11:80 check
    server gitlab3 10.0.1.12:80 check

frontend gitlab_ssh
    mode tcp
    bind *:22
    default_backend gitlab_ssh_backend

backend gitlab_ssh_backend
    mode tcp
    balance roundrobin
    server gitlab1 10.0.1.10:22 check
    server gitlab2 10.0.1.11:22 check
    server gitlab3 10.0.1.12:22 check
```

## Advanced User and Group Management

### 1. LDAP Integration
```ruby
# /etc/gitlab/gitlab.rb - LDAP Configuration
gitlab_rails['ldap_enabled'] = true
gitlab_rails['prevent_ldap_sign_in'] = false

gitlab_rails['ldap_servers'] = YAML.load <<-'EOS'
  main:
    label: 'Company LDAP'
    host: 'ldap.company.com'
    port: 636
    uid: 'sAMAccountName'
    bind_dn: 'CN=gitlab,OU=Service Accounts,DC=company,DC=com'
    password: 'ldap_password'
    encryption: 'simple_tls'
    verify_certificates: true
    ca_file: '/etc/ssl/certs/company-ca.crt'
    ssl_version: 'TLSv1_2'
    base: 'DC=company,DC=com'
    user_filter: '(&(objectCategory=person)(objectClass=user)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))'
    attributes:
      username: ['uid', 'userid', 'sAMAccountName']
      email: ['mail', 'email', 'userPrincipalName']
      name: 'cn'
      first_name: 'givenName'
      last_name: 'sn'
    group_base: 'OU=Groups,DC=company,DC=com'
    admin_group: 'CN=GitLab Admins,OU=Groups,DC=company,DC=com'
    external_groups: ['CN=Contractors,OU=Groups,DC=company,DC=com']
    sync_ssh_keys: true
EOS
```

### 2. SAML SSO Configuration
```ruby
# /etc/gitlab/gitlab.rb - SAML Configuration
gitlab_rails['omniauth_enabled'] = true
gitlab_rails['omniauth_allow_single_sign_on'] = ['saml']
gitlab_rails['omniauth_sync_email_from_provider'] = 'saml'
gitlab_rails['omniauth_sync_profile_from_provider'] = ['saml']
gitlab_rails['omniauth_sync_profile_attributes'] = ['email']
gitlab_rails['omniauth_auto_sign_in_with_provider'] = 'saml'
gitlab_rails['omniauth_block_auto_created_users'] = false
gitlab_rails['omniauth_auto_link_ldap_user'] = false
gitlab_rails['omniauth_auto_link_saml_user'] = true

gitlab_rails['omniauth_providers'] = [
  {
    name: 'saml',
    args: {
      assertion_consumer_service_url: 'https://gitlab.company.com/users/auth/saml/callback',
      idp_cert_fingerprint: 'FINGERPRINT',
      idp_sso_target_url: 'https://sso.company.com/saml/sso',
      issuer: 'https://gitlab.company.com',
      name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
      attribute_statements: {
        email: ['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'],
        name: ['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'],
        username: ['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name']
      }
    },
    label: 'Company SSO'
  }
]
```

### 3. Advanced Group Management
```bash
# Group management via API
#!/bin/bash

API_TOKEN="your-admin-token"
GITLAB_URL="https://gitlab.company.com"

# Create enterprise group structure
create_group() {
    local name=$1
    local path=$2
    local parent_id=$3
    
    curl --request POST \
        --header "PRIVATE-TOKEN: $API_TOKEN" \
        --header "Content-Type: application/json" \
        --data "{
            \"name\": \"$name\",
            \"path\": \"$path\",
            \"parent_id\": $parent_id,
            \"visibility\": \"private\",
            \"project_creation_level\": \"maintainer\",
            \"subgroup_creation_level\": \"maintainer\"
        }" \
        "$GITLAB_URL/api/v4/groups"
}

# Create organizational structure
create_group "Engineering" "engineering" ""
create_group "Frontend Team" "frontend" "$(get_group_id engineering)"
create_group "Backend Team" "backend" "$(get_group_id engineering)"
create_group "DevOps Team" "devops" "$(get_group_id engineering)"

# Bulk user management
manage_group_members() {
    local group_id=$1
    local users_file=$2
    
    while IFS=',' read -r username access_level; do
        curl --request POST \
            --header "PRIVATE-TOKEN: $API_TOKEN" \
            --data "user_id=$(get_user_id $username)&access_level=$access_level" \
            "$GITLAB_URL/api/v4/groups/$group_id/members"
    done < "$users_file"
}
```

## License Management

### 1. Enterprise License Configuration
```ruby
# /etc/gitlab/gitlab.rb - License Management
gitlab_rails['license_file'] = '/etc/gitlab/GitLabEE.gitlab-license'

# Feature controls
gitlab_rails['usage_ping_enabled'] = true
gitlab_rails['sentry_enabled'] = false

# Seat management
gitlab_rails['max_attachment_size'] = 100  # MB
gitlab_rails['repository_size_limit'] = 10240  # MB per repository
```

### 2. License Monitoring Script
```python
#!/usr/bin/env python3
import requests
import json
from datetime import datetime, timedelta

class GitLabLicenseMonitor:
    def __init__(self, gitlab_url, api_token):
        self.gitlab_url = gitlab_url
        self.headers = {'PRIVATE-TOKEN': api_token}
    
    def get_license_info(self):
        """Get current license information"""
        response = requests.get(
            f"{self.gitlab_url}/api/v4/license",
            headers=self.headers
        )
        return response.json()
    
    def get_user_count(self):
        """Get current active user count"""
        response = requests.get(
            f"{self.gitlab_url}/api/v4/users?active=true&per_page=100",
            headers=self.headers
        )
        
        total_users = int(response.headers.get('X-Total', 0))
        return total_users
    
    def check_license_compliance(self):
        """Check license compliance and usage"""
        license_info = self.get_license_info()
        user_count = self.get_user_count()
        
        licensed_users = license_info.get('user_limit', 0)
        expires_at = license_info.get('expires_at')
        
        # Check user limit
        usage_percentage = (user_count / licensed_users) * 100
        
        # Check expiration
        expiry_date = datetime.fromisoformat(expires_at.replace('Z', '+00:00'))
        days_until_expiry = (expiry_date - datetime.now()).days
        
        return {
            'licensed_users': licensed_users,
            'active_users': user_count,
            'usage_percentage': usage_percentage,
            'days_until_expiry': days_until_expiry,
            'compliance_status': 'compliant' if user_count <= licensed_users else 'over_limit'
        }
    
    def generate_usage_report(self):
        """Generate detailed usage report"""
        compliance = self.check_license_compliance()
        
        report = f"""
GitLab License Usage Report
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

License Information:
- Licensed Users: {compliance['licensed_users']}
- Active Users: {compliance['active_users']}
- Usage: {compliance['usage_percentage']:.1f}%
- Days Until Expiry: {compliance['days_until_expiry']}
- Status: {compliance['compliance_status'].upper()}

Recommendations:
"""
        
        if compliance['usage_percentage'] > 90:
            report += "- Consider purchasing additional licenses\n"
        
        if compliance['days_until_expiry'] < 30:
            report += "- License renewal required soon\n"
        
        return report

# Usage
monitor = GitLabLicenseMonitor('https://gitlab.company.com', 'admin-token')
print(monitor.generate_usage_report())
```

## System Monitoring and Maintenance

### 1. Comprehensive Monitoring Setup
```yaml
# docker-compose.yml - Monitoring Stack
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/datasources:/etc/grafana/provisioning/datasources

  alertmanager:
    image: prom/alertmanager:latest
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml

volumes:
  prometheus_data:
  grafana_data:
```

### 2. GitLab Metrics Configuration
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "gitlab_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'gitlab'
    static_configs:
      - targets: ['gitlab.company.com:9090']
    metrics_path: /-/metrics
    
  - job_name: 'gitlab-workhorse'
    static_configs:
      - targets: ['gitlab.company.com:9229']
      
  - job_name: 'gitlab-pages'
    static_configs:
      - targets: ['gitlab.company.com:9235']
      
  - job_name: 'gitaly'
    static_configs:
      - targets: ['gitaly.company.com:9236']
      
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres.company.com:9187']
      
  - job_name: 'redis'
    static_configs:
      - targets: ['redis.company.com:9121']
```

### 3. Automated Maintenance Scripts
```bash
#!/bin/bash
# gitlab-maintenance.sh

GITLAB_HOME="/opt/gitlab"
BACKUP_DIR="/var/opt/gitlab/backups"
LOG_FILE="/var/log/gitlab/maintenance.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Database maintenance
database_maintenance() {
    log "Starting database maintenance"
    
    # Vacuum and analyze
    sudo -u gitlab-psql /opt/gitlab/embedded/bin/psql -h /var/opt/gitlab/postgresql -d gitlabhq_production -c "VACUUM ANALYZE;"
    
    # Update statistics
    sudo -u gitlab-psql /opt/gitlab/embedded/bin/psql -h /var/opt/gitlab/postgresql -d gitlabhq_production -c "ANALYZE;"
    
    log "Database maintenance completed"
}

# Cleanup old artifacts
cleanup_artifacts() {
    log "Starting artifact cleanup"
    
    # Remove artifacts older than 30 days
    find /var/opt/gitlab/gitlab-rails/shared/artifacts -type f -mtime +30 -delete
    
    # Remove old CI logs
    find /var/opt/gitlab/gitlab-ci/builds -type f -mtime +7 -delete
    
    log "Artifact cleanup completed"
}

# Repository maintenance
repository_maintenance() {
    log "Starting repository maintenance"
    
    # Run housekeeping on all repositories
    sudo gitlab-rake gitlab:git:fsck
    sudo gitlab-rake gitlab:cleanup:repos
    
    log "Repository maintenance completed"
}

# System health check
health_check() {
    log "Starting health check"
    
    # Check GitLab status
    sudo gitlab-ctl status
    
    # Check disk space
    df -h | grep -E "(/$|/var|/opt)"
    
    # Check memory usage
    free -h
    
    # Check load average
    uptime
    
    log "Health check completed"
}

# Main execution
main() {
    log "Starting GitLab maintenance routine"
    
    health_check
    database_maintenance
    cleanup_artifacts
    repository_maintenance
    
    log "GitLab maintenance routine completed"
}

main "$@"
```

## Performance Tuning

### 1. Application Server Optimization
```ruby
# /etc/gitlab/gitlab.rb - Performance Tuning
# Unicorn/Puma configuration
puma['enable'] = true
puma['worker_processes'] = 16
puma['min_threads'] = 4
puma['max_threads'] = 4
puma['worker_timeout'] = 60
puma['per_worker_max_memory_mb'] = 1024

# Sidekiq optimization
sidekiq['max_concurrency'] = 25
sidekiq['min_concurrency'] = 5
sidekiq['queue_groups'] = [
  "urgent,high",
  "default,low",
  "mailers"
]

# GitLab Rails optimization
gitlab_rails['env'] = {
  'MALLOC_CONF' => 'dirty_decay_ms:1000,muzzy_decay_ms:1000',
  'RUBY_GC_HEAP_GROWTH_FACTOR' => '1.1',
  'RUBY_GC_MALLOC_LIMIT' => '16777216',
  'RUBY_GC_OLDMALLOC_LIMIT' => '16777216'
}
```

### 2. Database Performance Tuning
```sql
-- PostgreSQL performance queries
-- Check slow queries
SELECT query, mean_time, calls, total_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;

-- Check index usage
SELECT schemaname, tablename, attname, n_distinct, correlation
FROM pg_stats
WHERE schemaname = 'public'
ORDER BY n_distinct DESC;

-- Optimize common queries
CREATE INDEX CONCURRENTLY idx_projects_on_namespace_id_and_name 
ON projects (namespace_id, name);

CREATE INDEX CONCURRENTLY idx_merge_requests_on_target_project_id_and_state 
ON merge_requests (target_project_id, state);
```

## Disaster Recovery

### 1. Backup Strategy
```bash
#!/bin/bash
# gitlab-backup.sh

BACKUP_DIR="/var/opt/gitlab/backups"
S3_BUCKET="gitlab-backups-company"
RETENTION_DAYS=30

# Create GitLab backup
gitlab-backup create BACKUP=dump

# Upload to S3
BACKUP_FILE=$(ls -t $BACKUP_DIR/*.tar | head -1)
aws s3 cp "$BACKUP_FILE" "s3://$S3_BUCKET/$(basename $BACKUP_FILE)"

# Cleanup old backups
find $BACKUP_DIR -name "*.tar" -mtime +$RETENTION_DAYS -delete

# Verify backup integrity
gitlab-backup restore BACKUP=$(basename $BACKUP_FILE .tar) --dry-run
```

### 2. Recovery Procedures
```bash
#!/bin/bash
# gitlab-recovery.sh

BACKUP_FILE=$1
S3_BUCKET="gitlab-backups-company"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file>"
    exit 1
fi

# Download backup from S3
aws s3 cp "s3://$S3_BUCKET/$BACKUP_FILE" "/var/opt/gitlab/backups/"

# Stop GitLab services
gitlab-ctl stop unicorn
gitlab-ctl stop puma
gitlab-ctl stop sidekiq

# Restore from backup
gitlab-backup restore BACKUP=$(basename $BACKUP_FILE .tar)

# Restart GitLab
gitlab-ctl restart
gitlab-rake gitlab:check SANITIZE=true
```

## Next Steps

After mastering enterprise administration:
1. Learn high availability and clustering
2. Implement advanced security frameworks
3. Develop custom integrations
4. Study performance optimization techniques

---
*Enterprise GitLab administration requires comprehensive planning, monitoring, and maintenance strategies.*