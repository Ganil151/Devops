# 🔐 Nginx Security & Performance Reference
*Version 1.0 | Hardening and Optimization*

---

## 📖 Overview
This reference covers production-grade security hardening and performance optimization techniques for Nginx. These patterns are essential for protecting infrastructure and delivering content at scale.

---

## 🛡️ Security Hardening

### SSL/TLS Best Practices

#### Modern SSL Configuration (A+ Rating)

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    
    # Certificates
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    
    # Protocols (TLS 1.2 and 1.3 only)
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;  # Let client choose for TLS 1.3
    
    # Cipher suites (Mozilla Modern)
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    
    # DH parameters
    ssl_dhparam /etc/ssl/certs/dhparam.pem;
    
    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/ssl/certs/ca-bundle.crt;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;
    
    # Session cache
    ssl_session_cache shared:SSL:50m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;
    
    # HSTS (HTTP Strict Transport Security)
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
}
```

**Generate DH parameters**:
```bash
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
```

#### Certificate Management

```nginx
# Multiple domains with SNI (Server Name Indication)
server {
    listen 443 ssl http2;
    server_name example.com;
    
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
}

server {
    listen 443 ssl http2;
    server_name api.example.com;
    
    ssl_certificate /etc/ssl/certs/api.example.com.crt;
    ssl_certificate_key /etc/ssl/private/api.example.com.key;
}
```

---

### Security Headers

#### Complete Security Headers Suite

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    
    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    
    # Prevent clickjacking
    add_header X-Frame-Options "SAMEORIGIN" always;
    
    # Prevent MIME sniffing
    add_header X-Content-Type-Options "nosniff" always;
    
    # XSS Protection (legacy browsers)
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Referrer Policy
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Content Security Policy
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.example.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https://api.example.com; frame-ancestors 'self'; base-uri 'self'; form-action 'self';" always;
    
    # Permissions Policy (formerly Feature-Policy)
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=(), payment=(), usb=(), magnetometer=(), gyroscope=(), accelerometer=()" always;
    
    # Remove server version
    server_tokens off;
    more_clear_headers Server;  # Requires headers-more module
}
```

#### CSP (Content Security Policy) Builder

```nginx
# Strict CSP
add_header Content-Security-Policy "default-src 'none'; script-src 'self'; style-src 'self'; img-src 'self'; font-src 'self'; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self';" always;

# Moderate CSP (allows CDNs)
add_header Content-Security-Policy "default-src 'self'; script-src 'self' https://cdn.jsdelivr.net; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https://api.example.com;" always;

# Report-only mode (testing)
add_header Content-Security-Policy-Report-Only "default-src 'self'; report-uri /csp-report;" always;
```

---

### Access Control

#### IP-Based Access Control

```nginx
# Whitelist approach
server {
    listen 80;
    server_name admin.example.com;
    
    # Allow office network
    allow 203.0.113.0/24;
    
    # Allow VPN
    allow 198.51.100.0/24;
    
    # Allow specific IPs
    allow 192.0.2.10;
    allow 192.0.2.11;
    
    # Deny everyone else
    deny all;
    
    location / {
        proxy_pass http://admin_backend;
    }
}

# Blacklist approach
server {
    listen 80;
    
    # Block known bad actors
    deny 192.0.2.50;
    deny 198.51.100.0/24;
    
    # Allow everyone else
    allow all;
}
```

#### Geo-Blocking

```nginx
http {
    # Define allowed countries
    geo $allowed_country {
        default 0;
        
        # Allow US
        include /etc/nginx/geo/us.conf;
        
        # Allow Canada
        include /etc/nginx/geo/ca.conf;
        
        # Allow UK
        include /etc/nginx/geo/uk.conf;
    }
    
    server {
        listen 80;
        
        if ($allowed_country = 0) {
            return 403 "Access denied from your country";
        }
        
        location / {
            root /var/www/html;
        }
    }
}
```

#### User-Agent Blocking

```nginx
http {
    # Block bad bots
    map $http_user_agent $bad_bot {
        default 0;
        ~*Scrapy 1;
        ~*AhrefsBot 1;
        ~*SemrushBot 1;
        ~*MJ12bot 1;
        ~*DotBot 1;
    }
    
    server {
        listen 80;
        
        if ($bad_bot) {
            return 403 "Bot access denied";
        }
        
        location / {
            root /var/www/html;
        }
    }
}
```

---

### Rate Limiting & DDoS Protection

#### Multi-Tier Rate Limiting

```nginx
http {
    # Global rate limit (per IP)
    limit_req_zone $binary_remote_addr zone=global:10m rate=100r/s;
    
    # API rate limit
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    
    # Login rate limit (very strict)
    limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;
    
    # Search rate limit
    limit_req_zone $binary_remote_addr zone=search:10m rate=20r/m;
    
    # Connection limit
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    server {
        listen 80;
        
        # Global limit
        limit_req zone=global burst=200 nodelay;
        limit_conn conn_limit 10;
        
        # API endpoints
        location /api {
            limit_req zone=api burst=20 nodelay;
            limit_req_status 429;
            
            proxy_pass http://backend;
        }
        
        # Login endpoint (strictest)
        location /login {
            limit_req zone=login burst=3;
            limit_req_status 429;
            
            proxy_pass http://backend;
        }
        
        # Search endpoint
        location /search {
            limit_req zone=search burst=10;
            
            proxy_pass http://backend;
        }
    }
}
```

#### Slowloris Protection

```nginx
http {
    # Client request timeouts
    client_body_timeout 10s;
    client_header_timeout 10s;
    
    # Limit request size
    client_max_body_size 10m;
    client_body_buffer_size 128k;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 8k;
    
    # Connection limits
    limit_conn_zone $binary_remote_addr zone=addr:10m;
    
    server {
        listen 80;
        
        # Max 10 connections per IP
        limit_conn addr 10;
        
        # Send timeout
        send_timeout 10s;
        
        # Keep-alive timeout
        keepalive_timeout 15s;
        keepalive_requests 100;
    }
}
```

---

## 🚀 Performance Optimization

### Caching Strategies

#### Proxy Caching

```nginx
http {
    # Cache path configuration
    proxy_cache_path /var/cache/nginx/proxy
        levels=1:2
        keys_zone=proxy_cache:100m
        max_size=10g
        inactive=60m
        use_temp_path=off;
    
    # Cache for static API responses
    proxy_cache_path /var/cache/nginx/api
        levels=1:2
        keys_zone=api_cache:50m
        max_size=5g
        inactive=30m
        use_temp_path=off;
    
    server {
        listen 80;
        
        location / {
            proxy_pass http://backend;
            
            # Enable caching
            proxy_cache proxy_cache;
            
            # Cache valid responses
            proxy_cache_valid 200 302 60m;
            proxy_cache_valid 404 10m;
            proxy_cache_valid any 1m;
            
            # Cache key
            proxy_cache_key "$scheme$request_method$host$request_uri$is_args$args";
            
            # Bypass cache for authenticated users
            proxy_cache_bypass $http_authorization $cookie_session;
            proxy_no_cache $http_authorization $cookie_session;
            
            # Cache lock (prevent stampede)
            proxy_cache_lock on;
            proxy_cache_lock_timeout 5s;
            
            # Serve stale content if backend is down
            proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
            proxy_cache_background_update on;
            
            # Add cache status header
            add_header X-Cache-Status $upstream_cache_status;
        }
        
        # API caching with different rules
        location /api {
            proxy_pass http://api_backend;
            
            proxy_cache api_cache;
            proxy_cache_valid 200 5m;
            
            # Only cache GET requests
            proxy_cache_methods GET HEAD;
            
            # Bypass cache with specific header
            proxy_cache_bypass $http_x_no_cache;
        }
    }
}
```

#### Browser Caching

```nginx
server {
    listen 80;
    root /var/www/html;
    
    # Versioned assets (cache forever)
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # HTML (no cache)
    location ~* \.html$ {
        expires -1;
        add_header Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0";
    }
    
    # API responses (short cache)
    location /api {
        proxy_pass http://backend;
        expires 5m;
        add_header Cache-Control "public, max-age=300";
    }
}
```

---

### Compression

#### Gzip Compression (Optimized)

```nginx
http {
    # Enable gzip
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;  # 1-9 (6 is optimal)
    gzip_min_length 256;  # Don't compress small files
    
    # Compression types
    gzip_types
        application/atom+xml
        application/geo+json
        application/javascript
        application/x-javascript
        application/json
        application/ld+json
        application/manifest+json
        application/rdf+xml
        application/rss+xml
        application/vnd.ms-fontobject
        application/wasm
        application/x-web-app-manifest+json
        application/xhtml+xml
        application/xml
        font/eot
        font/otf
        font/ttf
        image/bmp
        image/svg+xml
        text/cache-manifest
        text/calendar
        text/css
        text/javascript
        text/markdown
        text/plain
        text/xml
        text/x-component
        text/x-cross-domain-policy;
    
    # Don't compress for old IE
    gzip_disable "msie6";
    
    # Compression buffer
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
}
```

#### Brotli Compression (Better than Gzip)

```nginx
# Requires ngx_brotli module
http {
    # Enable brotli
    brotli on;
    brotli_comp_level 6;
    brotli_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/rss+xml
        font/truetype
        font/opentype
        application/vnd.ms-fontobject
        image/svg+xml;
    
    # Static brotli (pre-compressed files)
    brotli_static on;
}
```

---

### Connection Optimization

#### HTTP/2 Optimization

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    
    # HTTP/2 push (preload critical resources)
    location = /index.html {
        http2_push /css/main.css;
        http2_push /js/app.js;
        http2_push /fonts/main.woff2;
    }
    
    # HTTP/2 settings
    http2_max_field_size 16k;
    http2_max_header_size 32k;
}
```

#### Upstream Keep-Alive

```nginx
upstream backend {
    server 192.168.1.10:8080;
    server 192.168.1.11:8080;
    
    # Keep 32 idle connections to each server
    keepalive 32;
    keepalive_timeout 60s;
    keepalive_requests 100;
}

server {
    location / {
        proxy_pass http://backend;
        
        # Required for keep-alive
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
```

---

### Buffer Optimization

```nginx
http {
    # Client buffers
    client_body_buffer_size 128k;
    client_max_body_size 10m;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 8k;
    
    # Proxy buffers
    proxy_buffer_size 4k;
    proxy_buffers 8 4k;
    proxy_busy_buffers_size 8k;
    proxy_temp_file_write_size 8k;
    
    # FastCGI buffers (PHP)
    fastcgi_buffer_size 4k;
    fastcgi_buffers 8 4k;
    fastcgi_busy_buffers_size 8k;
    
    # Output buffers
    output_buffers 2 32k;
    postpone_output 1460;  # MTU size
}
```

---

## 📊 Monitoring & Logging

### Performance Logging

```nginx
http {
    # Detailed performance log format
    log_format performance '$remote_addr - $remote_user [$time_local] '
                          '"$request" $status $body_bytes_sent '
                          '"$http_referer" "$http_user_agent" '
                          'rt=$request_time '
                          'uct="$upstream_connect_time" '
                          'uht="$upstream_header_time" '
                          'urt="$upstream_response_time" '
                          'cs=$upstream_cache_status';
    
    server {
        access_log /var/log/nginx/performance.log performance;
    }
}
```

### Stub Status Module

```nginx
server {
    listen 127.0.0.1:80;
    server_name localhost;
    
    location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        deny all;
    }
}
```

**Output**:
```
Active connections: 291
server accepts handled requests
 16630948 16630948 31070465
Reading: 6 Writing: 179 Waiting: 106
```

---

## 🛡️ SRE Best Practices

### Production Checklist

```nginx
# /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
worker_rlimit_nofile 65535;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}

http {
    # Basic settings
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
    access_log /var/log/nginx/access.log main;
    
    # Performance
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;
    
    # Buffers
    client_body_buffer_size 128k;
    client_max_body_size 10m;
    
    # Timeouts
    client_body_timeout 12;
    client_header_timeout 12;
    send_timeout 10;
    
    # Gzip
    gzip on;
    gzip_vary on;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
    
    # Security
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Include configs
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
```

---

## ❓ Interview "Deep-Cut" Questions

1. **Explain the difference between `proxy_cache_bypass` and `proxy_no_cache`.**
   - *Answer*: `proxy_cache_bypass` determines whether to skip reading from cache (but still stores response). `proxy_no_cache` determines whether to skip storing response in cache. Use both together to completely bypass cache for authenticated users.

2. **How does Nginx's `proxy_cache_lock` prevent cache stampede?**
   - *Answer*: When multiple requests for uncached content arrive simultaneously, only the first request fetches from upstream. Others wait for the first request to complete and populate cache. This prevents overwhelming the backend with duplicate requests.

3. **What's the security risk of using `if` in Nginx configuration?**
   - *Answer*: The `if` directive has unexpected behavior in location context (known as "if is evil"). It can cause request processing to break, variables to behave unexpectedly, and security rules to be bypassed. Prefer `map`, `try_files`, or separate location blocks.

4. **Explain how `ssl_session_tickets off` improves security.**
   - *Answer*: Session tickets encrypt session data with a key shared across servers. If this key is compromised, past sessions can be decrypted (breaks perfect forward secrecy). Disabling tickets forces full TLS handshake, ensuring each session uses unique keys.

5. **How do you calculate optimal `worker_processes` and `worker_connections`?**
   - *Answer*: `worker_processes` should equal CPU cores (`auto` is recommended). `worker_connections` depends on available file descriptors and expected load. Formula: `max_clients = worker_processes * worker_connections / 2` (divide by 2 because each connection uses 2 file descriptors for proxy). Check limits with `ulimit -n`.

---

**Next Step**: [Nginx Troubleshooting →](./nginx-troubleshooting-ref.md)
