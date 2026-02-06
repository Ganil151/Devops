# 🔧 Nginx Troubleshooting & Operations Reference
*Version 1.0 | Debugging and Operational Excellence*

---

## 📖 Overview
This reference provides systematic approaches to diagnosing and resolving common Nginx issues, along with operational best practices for production environments.

---

## 🐛 Common Issues & Solutions

### 502 Bad Gateway

**Symptoms**: Nginx returns 502 status code

**Common Causes**:

#### 1. Backend Server Down

```bash
# Check if backend is running
curl http://127.0.0.1:8080

# Check Nginx error log
tail -f /var/log/nginx/error.log
# Look for: "connect() failed (111: Connection refused)"
```

**Solution**:
```bash
# Start backend service
systemctl start backend-app

# Verify it's listening
netstat -tlnp | grep 8080
# or
ss -tlnp | grep 8080
```

#### 2. Timeout Issues

```nginx
# Increase timeouts
location / {
    proxy_pass http://backend;
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;
}
```

#### 3. SELinux Blocking Connections

```bash
# Check SELinux status
getenforce

# Check audit log
ausearch -m avc -ts recent

# Allow Nginx to connect to network
setsebool -P httpd_can_network_connect 1
```

---

### 504 Gateway Timeout

**Symptoms**: Request times out after 60 seconds (default)

**Diagnosis**:
```bash
# Check error log
tail -f /var/log/nginx/error.log
# Look for: "upstream timed out (110: Connection timed out)"

# Test backend directly
time curl http://127.0.0.1:8080/slow-endpoint
```

**Solutions**:

```nginx
# Increase timeouts for slow endpoints
location /api/slow {
    proxy_pass http://backend;
    proxy_read_timeout 300s;  # 5 minutes
    proxy_send_timeout 300s;
}

# Or globally
http {
    proxy_read_timeout 120s;
    proxy_send_timeout 120s;
}
```

---

### 413 Request Entity Too Large

**Symptoms**: File upload fails with 413 error

**Solution**:
```nginx
http {
    # Increase max body size
    client_max_body_size 100m;
}

# Or per location
location /upload {
    client_max_body_size 500m;
    client_body_timeout 300s;
}
```

---

### 499 Client Closed Request

**Symptoms**: Client disconnects before Nginx finishes processing

**Diagnosis**:
```bash
# Check access log
grep " 499 " /var/log/nginx/access.log

# Common causes:
# - Slow backend response
# - Client timeout too short
# - Network issues
```

**Solutions**:
```nginx
# Ignore client abort
location / {
    proxy_pass http://backend;
    proxy_ignore_client_abort on;
}

# Speed up backend
# - Add caching
# - Optimize database queries
# - Add load balancing
```

---

### SSL Certificate Issues

#### Certificate Not Trusted

```bash
# Test SSL certificate
openssl s_client -connect example.com:443 -servername example.com

# Check certificate chain
openssl s_client -connect example.com:443 -showcerts

# Verify certificate
openssl x509 -in /etc/ssl/certs/example.com.crt -text -noout
```

**Solution**:
```nginx
# Include full certificate chain
ssl_certificate /etc/ssl/certs/example.com-fullchain.crt;
ssl_certificate_key /etc/ssl/private/example.com.key;

# Add intermediate certificates
ssl_trusted_certificate /etc/ssl/certs/ca-bundle.crt;
```

#### Certificate Expired

```bash
# Check expiration
openssl x509 -in /etc/ssl/certs/example.com.crt -noout -dates

# Renew Let's Encrypt certificate
certbot renew --nginx

# Test renewal
certbot renew --dry-run
```

---

## 🔍 Debugging Techniques

### Enable Debug Logging

```nginx
# Temporary debug logging
error_log /var/log/nginx/debug.log debug;

# Debug specific connection
events {
    debug_connection 192.168.1.10;
    debug_connection 192.168.1.0/24;
}
```

**Warning**: Debug logging is very verbose. Use only for troubleshooting.

### Test Configuration

```bash
# Test syntax
nginx -t

# Test and show full configuration
nginx -T

# Show version and modules
nginx -V
```

### Reload vs Restart

```bash
# Graceful reload (no downtime)
nginx -s reload
# or
systemctl reload nginx

# Restart (brief downtime)
systemctl restart nginx

# Stop gracefully (finish current requests)
nginx -s quit

# Stop immediately
nginx -s stop
```

---

## 📊 Performance Debugging

### Identify Slow Requests

```nginx
# Add timing to log format
log_format timing '$remote_addr - $remote_user [$time_local] '
                  '"$request" $status $body_bytes_sent '
                  'rt=$request_time uct="$upstream_connect_time" '
                  'uht="$upstream_header_time" urt="$upstream_response_time"';

access_log /var/log/nginx/timing.log timing;
```

**Analyze logs**:
```bash
# Find slowest requests
awk '{print $NF, $7}' /var/log/nginx/timing.log | sort -rn | head -20

# Average request time
awk '{sum+=$NF; count++} END {print sum/count}' /var/log/nginx/timing.log
```

### Check Worker Processes

```bash
# Show worker processes
ps aux | grep nginx

# Check worker CPU usage
top -p $(pgrep -d',' nginx)

# Check open connections
netstat -an | grep :80 | wc -l

# Check file descriptors
lsof -p $(pgrep nginx | head -1) | wc -l
```

### Monitor Cache Performance

```nginx
# Add cache status to logs
log_format cache '$remote_addr - $remote_user [$time_local] '
                 '"$request" $status $body_bytes_sent '
                 'cs=$upstream_cache_status rt=$request_time';

access_log /var/log/nginx/cache.log cache;
```

**Analyze cache hits**:
```bash
# Cache hit rate
awk '{print $NF}' /var/log/nginx/cache.log | sort | uniq -c
# Look for: HIT, MISS, BYPASS, EXPIRED, STALE, UPDATING
```

---

## 🛠️ Operational Tasks

### Log Rotation

```bash
# /etc/logrotate.d/nginx
/var/log/nginx/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 nginx adm
    sharedscripts
    postrotate
        [ -f /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
    endscript
}
```

**Manual rotation**:
```bash
# Rotate logs manually
mv /var/log/nginx/access.log /var/log/nginx/access.log.1
nginx -s reopen
```

### Zero-Downtime Deployment

```bash
# 1. Test new configuration
nginx -t

# 2. Reload configuration
nginx -s reload

# 3. Verify reload
ps aux | grep nginx
# Should see new worker processes

# 4. Monitor error log
tail -f /var/log/nginx/error.log
```

### Binary Upgrade (No Downtime)

```bash
# 1. Backup current binary
cp /usr/sbin/nginx /usr/sbin/nginx.old

# 2. Replace binary
cp /path/to/new/nginx /usr/sbin/nginx

# 3. Send USR2 signal (start new master)
kill -USR2 `cat /var/run/nginx.pid`

# 4. Gracefully shutdown old workers
kill -WINCH `cat /var/run/nginx.pid.oldbin`

# 5. If successful, quit old master
kill -QUIT `cat /var/run/nginx.pid.oldbin`

# 6. If issues, rollback
kill -HUP `cat /var/run/nginx.pid.oldbin`
kill -QUIT `cat /var/run/nginx.pid`
mv /usr/sbin/nginx.old /usr/sbin/nginx
```

---

## 📈 Monitoring & Metrics

### Prometheus Exporter

```nginx
# Install nginx-prometheus-exporter
# https://github.com/nginxinc/nginx-prometheus-exporter

# Enable stub_status
server {
    listen 127.0.0.1:8080;
    location /stub_status {
        stub_status;
        access_log off;
    }
}
```

**Run exporter**:
```bash
nginx-prometheus-exporter -nginx.scrape-uri=http://127.0.0.1:8080/stub_status
```

### Key Metrics to Monitor

```yaml
# Prometheus metrics
- nginx_connections_active
- nginx_connections_reading
- nginx_connections_writing
- nginx_connections_waiting
- nginx_http_requests_total
- nginx_up

# Custom metrics from logs
- request_duration_seconds
- upstream_response_time_seconds
- cache_hit_ratio
- error_rate_by_status_code
- requests_per_second
```

### Health Check Endpoint

```nginx
server {
    listen 80;
    
    # Health check
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    # Readiness check (includes backend)
    location /ready {
        access_log off;
        proxy_pass http://backend/health;
        proxy_connect_timeout 1s;
        proxy_read_timeout 1s;
    }
}
```

---

## 🔐 Security Incident Response

### Detect Suspicious Activity

```bash
# Find IPs with most requests
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -20

# Find 404 errors (scanning)
grep " 404 " /var/log/nginx/access.log | awk '{print $1}' | sort | uniq -c | sort -rn

# Find POST requests
grep "POST" /var/log/nginx/access.log | awk '{print $1, $7}' | sort | uniq -c | sort -rn

# Find SQL injection attempts
grep -i "union.*select" /var/log/nginx/access.log

# Find XSS attempts
grep -i "<script" /var/log/nginx/access.log
```

### Block Malicious IP

```nginx
# Quick block in config
server {
    # Block specific IP
    deny 192.0.2.100;
    
    # Block range
    deny 192.0.2.0/24;
    
    allow all;
}
```

**Or use firewall**:
```bash
# iptables
iptables -A INPUT -s 192.0.2.100 -j DROP

# firewalld
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.0.2.100" reject'
firewall-cmd --reload
```

---

## 🚨 Emergency Procedures

### High CPU Usage

```bash
# 1. Identify cause
top -p $(pgrep -d',' nginx)

# 2. Check for regex in config
# Complex regex can cause high CPU
grep -r "~" /etc/nginx/

# 3. Check for infinite redirects
curl -I -L http://example.com

# 4. Temporary fix: reduce workers
# Edit /etc/nginx/nginx.conf
worker_processes 2;  # Reduce from auto

# 5. Reload
nginx -s reload
```

### Memory Leak

```bash
# 1. Monitor memory
watch -n 1 'ps aux | grep nginx'

# 2. Check for large buffers
grep -r "buffer" /etc/nginx/

# 3. Restart workers periodically
# Add to cron
0 3 * * * /usr/sbin/nginx -s reload
```

### Disk Full (Logs)

```bash
# 1. Check disk usage
df -h

# 2. Find large log files
du -sh /var/log/nginx/*

# 3. Emergency cleanup
> /var/log/nginx/access.log
> /var/log/nginx/error.log

# 4. Reload to reopen logs
nginx -s reopen

# 5. Fix log rotation
logrotate -f /etc/logrotate.d/nginx
```

---

## 📋 Operational Checklists

### Pre-Deployment Checklist

- [ ] Test configuration: `nginx -t`
- [ ] Review changes: `diff old.conf new.conf`
- [ ] Backup current config: `cp nginx.conf nginx.conf.backup`
- [ ] Check disk space: `df -h`
- [ ] Verify SSL certificates: `openssl x509 -in cert.crt -noout -dates`
- [ ] Test in staging environment
- [ ] Schedule maintenance window
- [ ] Notify team

### Post-Deployment Checklist

- [ ] Verify reload successful: `systemctl status nginx`
- [ ] Check error log: `tail -f /var/log/nginx/error.log`
- [ ] Monitor access log: `tail -f /var/log/nginx/access.log`
- [ ] Test endpoints: `curl -I https://example.com`
- [ ] Check SSL: `openssl s_client -connect example.com:443`
- [ ] Monitor metrics (CPU, memory, connections)
- [ ] Verify cache hit rate
- [ ] Check upstream health

### Incident Response Checklist

- [ ] Identify issue (502, 504, high CPU, etc.)
- [ ] Check error logs
- [ ] Check backend health
- [ ] Review recent changes
- [ ] Check system resources (CPU, memory, disk)
- [ ] Review metrics/monitoring
- [ ] Implement fix or rollback
- [ ] Verify resolution
- [ ] Document incident
- [ ] Post-mortem review

---

## 🛡️ Best Practices

### Configuration Management

```bash
# Use version control
cd /etc/nginx
git init
git add .
git commit -m "Initial nginx config"

# Before changes
git diff nginx.conf

# After changes
git add nginx.conf
git commit -m "Increase proxy timeout for /api"
```

### Testing in Staging

```nginx
# Use different server_name for staging
server {
    listen 80;
    server_name staging.example.com;
    
    # Same config as production
    location / {
        proxy_pass http://staging-backend;
    }
}
```

### Automated Testing

```bash
#!/bin/bash
# test-nginx.sh

# Test syntax
nginx -t || exit 1

# Test specific endpoints
curl -f http://localhost/health || exit 1
curl -f http://localhost/ || exit 1

# Check SSL
echo | openssl s_client -connect localhost:443 2>&1 | grep -q "Verify return code: 0" || exit 1

echo "All tests passed"
```

---

## ❓ Interview "Deep-Cut" Questions

1. **How do you diagnose a 502 error when the backend server is running and accessible?**
   - *Answer*: Check SELinux (`getenforce`, `ausearch -m avc`), firewall rules (`iptables -L`, `firewall-cmd --list-all`), backend listening address (127.0.0.1 vs 0.0.0.0), proxy_pass URL (trailing slash), and Nginx error logs for specific connection errors.

2. **Explain the difference between `nginx -s reload` and `systemctl restart nginx`.**
   - *Answer*: `reload` is graceful - master process spawns new workers with new config, old workers finish current requests then exit (no dropped connections). `restart` stops all processes immediately and starts fresh (brief downtime, dropped connections).

3. **How do you perform a zero-downtime Nginx binary upgrade?**
   - *Answer*: Send USR2 to master (starts new master with new binary), send WINCH to old master (gracefully shutdown old workers), verify new workers are healthy, send QUIT to old master. If issues, send HUP to old master and QUIT to new master to rollback.

4. **What does `upstream_cache_status: STALE` mean and when is it useful?**
   - *Answer*: Nginx is serving expired cache content because backend is unreachable. Useful with `proxy_cache_use_stale error timeout` to maintain availability during backend outages. Trade-off: users get stale data vs no data.

5. **How do you debug intermittent 499 errors?**
   - *Answer*: Check `$request_time` in logs (slow backend?), test client timeout settings, check network stability, enable `proxy_ignore_client_abort on` to see if backend completes successfully, monitor backend response times, check if specific endpoints or clients affected.

---

**Back to Start**: [Nginx Architecture →](./nginx-architecture-ref.md)
