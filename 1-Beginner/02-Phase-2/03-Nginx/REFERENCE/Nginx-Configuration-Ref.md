# ⚙️ Nginx Configuration Patterns Reference
*Version 1.0 | Production-Ready Configuration Templates*

---

## 📖 Overview
This reference provides battle-tested Nginx configuration patterns for common DevOps scenarios. Each pattern includes explanations, best practices, and real-world use cases.

---

## 🌐 Reverse Proxy Patterns

### Basic Reverse Proxy

```nginx
server {
    listen 80;
    server_name example.com;
    
    location / {
        proxy_pass http://127.0.0.1:8080;
        
        # Essential proxy headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**Headers Explained**:
- `Host`: Preserves original host header
- `X-Real-IP`: Client's actual IP address
- `X-Forwarded-For`: Chain of proxy IPs
- `X-Forwarded-Proto`: Original protocol (http/https)

### Reverse Proxy with Buffering Control

```nginx
server {
    listen 80;
    server_name api.example.com;
    
    location /api {
        proxy_pass http://backend;
        
        # Buffering (default: on)
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
        proxy_busy_buffers_size 8k;
        
        # Disable buffering for streaming
        # proxy_buffering off;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

**When to disable buffering**:
- Server-Sent Events (SSE)
- WebSocket connections
- Large file uploads
- Real-time streaming

### WebSocket Proxy

```nginx
http {
    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      close;
    }
    
    server {
        listen 80;
        server_name ws.example.com;
        
        location /ws {
            proxy_pass http://websocket_backend;
            
            # WebSocket headers
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            
            # Timeouts (keep connections alive)
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
        }
    }
}
```

---

## ⚖️ Load Balancing Patterns

### Round Robin (Default)

```nginx
upstream backend {
    server 192.168.1.10:8080;
    server 192.168.1.11:8080;
    server 192.168.1.12:8080;
}

server {
    listen 80;
    location / {
        proxy_pass http://backend;
    }
}
```

### Least Connections

```nginx
upstream backend {
    least_conn;  # Route to server with fewest active connections
    
    server 192.168.1.10:8080;
    server 192.168.1.11:8080;
    server 192.168.1.12:8080;
}
```

**Use case**: When backend servers have varying processing times

### IP Hash (Session Persistence)

```nginx
upstream backend {
    ip_hash;  # Same client always goes to same server
    
    server 192.168.1.10:8080;
    server 192.168.1.11:8080;
    server 192.168.1.12:8080;
}
```

**Use case**: Applications with server-side sessions (not recommended for stateless apps)

### Weighted Load Balancing

```nginx
upstream backend {
    server 192.168.1.10:8080 weight=3;  # 3x more traffic
    server 192.168.1.11:8080 weight=2;  # 2x more traffic
    server 192.168.1.12:8080 weight=1;  # 1x traffic (default)
}
```

**Use case**: Servers with different capacities

### Health Checks and Failover

```nginx
upstream backend {
    server 192.168.1.10:8080 max_fails=3 fail_timeout=30s;
    server 192.168.1.11:8080 max_fails=3 fail_timeout=30s;
    server 192.168.1.12:8080 backup;  # Only used if others fail
}
```

**Parameters**:
- `max_fails`: Failed attempts before marking down
- `fail_timeout`: Time to wait before retrying
- `backup`: Standby server

### Advanced Load Balancing

```nginx
upstream backend {
    least_conn;
    
    # Primary servers
    server 192.168.1.10:8080 weight=2 max_fails=2 fail_timeout=30s;
    server 192.168.1.11:8080 weight=2 max_fails=2 fail_timeout=30s;
    
    # Backup server
    server 192.168.1.12:8080 backup;
    
    # Maintenance mode (mark server as down)
    # server 192.168.1.13:8080 down;
    
    # Keep-alive connections to upstream
    keepalive 32;
    keepalive_timeout 60s;
}

server {
    location / {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";  # Required for keepalive
    }
}
```

---

## 🗂️ Static File Serving

### Basic Static Files

```nginx
server {
    listen 80;
    server_name static.example.com;
    root /var/www/static;
    
    location / {
        # Try file, then directory, then 404
        try_files $uri $uri/ =404;
    }
    
    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### Static Files with Fallback

```nginx
server {
    listen 80;
    server_name app.example.com;
    root /var/www/app;
    
    # Try static file first, then proxy to backend
    location / {
        try_files $uri $uri/ @backend;
    }
    
    location @backend {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
    }
}
```

### SPA (Single Page Application)

```nginx
server {
    listen 80;
    server_name spa.example.com;
    root /var/www/spa;
    index index.html;
    
    # All routes go to index.html (for client-side routing)
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # API requests go to backend
    location /api {
        proxy_pass http://backend;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

---

## 🔐 SSL/TLS Patterns

### Basic HTTPS

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    
    # Modern SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    
    location / {
        root /var/www/html;
    }
}
```

### HTTP to HTTPS Redirect

```nginx
server {
    listen 80;
    server_name example.com www.example.com;
    
    # Redirect all HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name example.com www.example.com;
    
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    
    location / {
        root /var/www/html;
    }
}
```

### SSL with OCSP Stapling

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    
    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/ssl/certs/ca-bundle.crt;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;
    
    # SSL session cache
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    location / {
        root /var/www/html;
    }
}
```

### Let's Encrypt with Certbot

```nginx
server {
    listen 80;
    server_name example.com;
    
    # ACME challenge for Let's Encrypt
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    # Redirect everything else to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name example.com;
    
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    
    location / {
        root /var/www/html;
    }
}
```

---

## 🚀 Performance Patterns

### Gzip Compression

```nginx
http {
    # Enable gzip
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;  # 1-9 (6 is good balance)
    gzip_types
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
    
    # Don't compress already compressed files
    gzip_disable "msie6";
    
    # Minimum file size to compress
    gzip_min_length 256;
}
```

### Caching

```nginx
# Proxy cache configuration
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=1g inactive=60m use_temp_path=off;

server {
    listen 80;
    server_name example.com;
    
    location / {
        proxy_pass http://backend;
        
        # Enable caching
        proxy_cache my_cache;
        proxy_cache_valid 200 60m;
        proxy_cache_valid 404 10m;
        
        # Cache key
        proxy_cache_key "$scheme$request_method$host$request_uri";
        
        # Add cache status header
        add_header X-Cache-Status $upstream_cache_status;
        
        # Bypass cache for specific conditions
        proxy_cache_bypass $http_pragma $http_authorization;
        proxy_no_cache $http_pragma $http_authorization;
    }
}
```

### Rate Limiting

```nginx
http {
    # Define rate limit zone (10MB can track ~160k IPs)
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=login_limit:10m rate=5r/m;
    
    server {
        listen 80;
        
        # API rate limiting
        location /api {
            limit_req zone=api_limit burst=20 nodelay;
            limit_req_status 429;
            
            proxy_pass http://backend;
        }
        
        # Login rate limiting (stricter)
        location /login {
            limit_req zone=login_limit burst=5;
            
            proxy_pass http://backend;
        }
    }
}
```

### Connection Limiting

```nginx
http {
    # Limit concurrent connections per IP
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    server {
        listen 80;
        
        location /download {
            # Max 2 concurrent connections per IP
            limit_conn conn_limit 2;
            limit_conn_status 429;
            
            # Limit bandwidth per connection
            limit_rate 500k;  # 500KB/s
            
            root /var/www/downloads;
        }
    }
}
```

---

## 🛡️ Security Patterns

### Security Headers

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
    
    location / {
        root /var/www/html;
    }
}
```

### IP Whitelisting

```nginx
# Geo-based blocking
geo $allowed_country {
    default 0;
    US 1;
    CA 1;
    GB 1;
}

server {
    listen 80;
    
    # Block by country
    if ($allowed_country = 0) {
        return 403;
    }
    
    # IP-based access control
    location /admin {
        # Allow specific IPs
        allow 192.168.1.0/24;
        allow 10.0.0.0/8;
        deny all;
        
        proxy_pass http://backend;
    }
}
```

### Basic Authentication

```nginx
server {
    listen 80;
    server_name admin.example.com;
    
    location / {
        auth_basic "Restricted Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
        
        proxy_pass http://backend;
    }
}
```

**Create password file**:
```bash
# Install htpasswd
apt-get install apache2-utils

# Create user
htpasswd -c /etc/nginx/.htpasswd admin

# Add more users (without -c)
htpasswd /etc/nginx/.htpasswd user2
```

---

## 🔄 Redirect Patterns

### WWW to Non-WWW

```nginx
server {
    listen 80;
    server_name www.example.com;
    return 301 $scheme://example.com$request_uri;
}

server {
    listen 80;
    server_name example.com;
    
    location / {
        root /var/www/html;
    }
}
```

### Old Domain to New Domain

```nginx
server {
    listen 80;
    server_name old-domain.com www.old-domain.com;
    return 301 $scheme://new-domain.com$request_uri;
}
```

### Specific Path Redirects

```nginx
server {
    listen 80;
    server_name example.com;
    
    # Exact match redirect
    location = /old-page {
        return 301 /new-page;
    }
    
    # Prefix redirect
    location /blog {
        return 301 /articles$request_uri;
    }
    
    # Regex redirect
    location ~ ^/product/(\d+)$ {
        return 301 /products/$1;
    }
}
```

---

## 📊 Logging Patterns

### Custom Log Format

```nginx
http {
    # Define custom log format
    log_format main '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
    
    log_format detailed '$remote_addr - $remote_user [$time_local] '
                        '"$request" $status $body_bytes_sent '
                        '"$http_referer" "$http_user_agent" '
                        'rt=$request_time uct="$upstream_connect_time" '
                        'uht="$upstream_header_time" urt="$upstream_response_time"';
    
    server {
        access_log /var/log/nginx/access.log main;
        error_log /var/log/nginx/error.log warn;
        
        location /api {
            access_log /var/log/nginx/api_access.log detailed;
        }
    }
}
```

### Conditional Logging

```nginx
http {
    # Don't log health checks
    map $request_uri $loggable {
        /health 0;
        /ping 0;
        default 1;
    }
    
    server {
        access_log /var/log/nginx/access.log combined if=$loggable;
    }
}
```

---

## ❓ Interview "Deep-Cut" Questions

1. **Explain the difference between `proxy_pass http://backend` and `proxy_pass http://backend/` when used in a location block.**
   - *Answer*: Without trailing slash, Nginx appends the full URI including the location prefix. With trailing slash, it replaces the location prefix. Example: `location /api { proxy_pass http://backend; }` sends `/api/users` to `http://backend/api/users`. With slash: `proxy_pass http://backend/;` sends `/api/users` to `http://backend/users`.

2. **How does `try_files` work and what's the difference between `try_files $uri $uri/ =404` and `try_files $uri $uri/ /index.html`?**
   - *Answer*: `try_files` checks files/directories in order. First example returns 404 if not found. Second example serves `/index.html` as fallback (common for SPAs). The `=404` syntax explicitly returns 404 status code.

3. **What's the purpose of `proxy_set_header Connection ""` when using upstream keepalive?**
   - *Answer*: HTTP/1.1 clients send `Connection: close` by default. This header clears it, allowing Nginx to maintain persistent connections to upstream servers, reducing connection overhead and improving performance.

4. **Explain the difference between `limit_req` and `limit_conn`.**
   - *Answer*: `limit_req` limits request rate (requests per second/minute). `limit_conn` limits concurrent connections. Use `limit_req` to prevent API abuse, `limit_conn` to prevent resource exhaustion from too many simultaneous downloads.

5. **How does Nginx's `ip_hash` load balancing handle server failures?**
   - *Answer*: When a server fails, its requests are redistributed to other servers. However, when it comes back online, the same clients will be routed back to it (based on IP hash). This can cause session loss if sessions aren't shared. Better to use sticky sessions with cookies or external session storage.

---

**Next Step**: [Nginx Load Balancing →](./Nginx-Load-Balancing-Ref.md)
