# 🏗️ Nginx Architecture Reference
*Version 1.0 | The Event-Driven Web Server*

---

## 📖 Overview
Nginx (Engine-X) is a high-performance, event-driven web server and reverse proxy that powers over 30% of the world's websites. Unlike traditional process-based servers (Apache), Nginx uses an asynchronous, non-blocking architecture that can handle thousands of concurrent connections with minimal resource usage.

**Created by**: Igor Sysoev (2004)  
**Philosophy**: "Do one thing extremely well: handle connections efficiently."

---

## 🏗️ Core Architecture

### Event-Driven Model

**Traditional (Apache MPM Prefork)**:
```
1 Process = 1 Connection
10,000 connections = 10,000 processes = ~10GB RAM
```

**Nginx (Event-Driven)**:
```
1 Worker Process = 10,000+ Connections
10,000 connections = 4-8 worker processes = ~100MB RAM
```

### Process Model

```
Master Process (root)
├── Worker Process 1 (nginx)
├── Worker Process 2 (nginx)
├── Worker Process 3 (nginx)
├── Worker Process 4 (nginx)
└── Cache Manager (nginx)
```

**Master Process**:
- Reads and validates configuration
- Manages worker processes
- Handles signals (reload, restart, stop)
- Runs as root (binds to ports < 1024)

**Worker Processes**:
- Handle actual client connections
- Run as unprivileged user (nginx)
- Each worker is single-threaded
- Number typically set to CPU cores

**Cache Manager**:
- Manages disk cache
- Removes expired cache entries
- Runs periodically

---

## ⚙️ Configuration Architecture

### Configuration Hierarchy

```nginx
# Main Context (Global)
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;

# Events Context
events {
    worker_connections 1024;
}

# HTTP Context
http {
    # Server Context
    server {
        listen 80;
        server_name example.com;
        
        # Location Context
        location / {
            root /var/www/html;
        }
        
        location /api {
            proxy_pass http://backend;
        }
    }
}
```

### Context Hierarchy

```
main
├── events
└── http
    ├── upstream
    ├── server
    │   └── location
    │       └── if
    └── types
```

---

## 🔧 Core Directives

### Worker Configuration

```nginx
# Number of worker processes (auto = number of CPU cores)
worker_processes auto;

# Maximum connections per worker
events {
    worker_connections 1024;  # Total: workers * connections
    use epoll;                # Linux: use epoll for better performance
}

# Worker priority (nice value: -20 to 19, lower = higher priority)
worker_priority -10;

# CPU affinity (bind workers to specific cores)
worker_cpu_affinity auto;
```

**Calculating Max Connections**:
```
Max Clients = worker_processes * worker_connections
Example: 4 workers * 1024 connections = 4096 concurrent clients
```

### File Handling

```nginx
http {
    # Optimize file serving
    sendfile on;              # Use kernel sendfile() instead of read()+write()
    tcp_nopush on;            # Send headers in one packet
    tcp_nodelay on;           # Don't buffer data
    
    # File descriptor cache
    open_file_cache max=1000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;
}
```

### Timeouts

```nginx
http {
    # Client timeouts
    client_body_timeout 12;      # Reading client request body
    client_header_timeout 12;    # Reading client request headers
    keepalive_timeout 65;        # Keep-alive connections
    send_timeout 10;             # Sending response to client
    
    # Proxy timeouts
    proxy_connect_timeout 60;    # Connecting to upstream
    proxy_send_timeout 60;       # Sending request to upstream
    proxy_read_timeout 60;       # Reading response from upstream
}
```

---

## 📊 Request Processing Flow

### Phase Order

```
1. Post-Read Phase
   ↓
2. Server Rewrite Phase (server block rewrite directives)
   ↓
3. Find Config Phase (location matching)
   ↓
4. Rewrite Phase (location block rewrite directives)
   ↓
5. Post-Rewrite Phase (internal redirect)
   ↓
6. Pre-Access Phase (limit_req, limit_conn)
   ↓
7. Access Phase (allow, deny, auth_basic)
   ↓
8. Post-Access Phase (satisfy directive)
   ↓
9. Try Files Phase (try_files directive)
   ↓
10. Content Phase (proxy_pass, fastcgi_pass, return)
    ↓
11. Log Phase (access_log)
```

### Location Matching Priority

```nginx
server {
    # 1. Exact match (highest priority)
    location = /exact {
        return 200 "Exact match";
    }
    
    # 2. Preferential prefix match
    location ^~ /images/ {
        return 200 "Preferential prefix";
    }
    
    # 3. Regex match (case-sensitive)
    location ~ \.php$ {
        return 200 "Regex match";
    }
    
    # 4. Regex match (case-insensitive)
    location ~* \.(jpg|jpeg|png|gif)$ {
        return 200 "Case-insensitive regex";
    }
    
    # 5. Prefix match (lowest priority)
    location / {
        return 200 "Prefix match";
    }
}
```

**Matching Order**:
1. `=` Exact match
2. `^~` Preferential prefix
3. `~` and `~*` Regex (first match wins)
4. Prefix (longest match wins)

---

## 🔄 Request Lifecycle Example

```nginx
http {
    upstream backend {
        server 192.168.1.10:8080;
        server 192.168.1.11:8080;
    }
    
    server {
        listen 80;
        server_name example.com;
        
        # Phase 1-2: Server rewrite
        rewrite ^/old-page$ /new-page permanent;
        
        # Phase 3-4: Location matching and rewrite
        location /api {
            # Phase 6: Rate limiting
            limit_req zone=api_limit burst=10;
            
            # Phase 7: Access control
            allow 192.168.1.0/24;
            deny all;
            
            # Phase 10: Content generation
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            
            # Phase 11: Logging
            access_log /var/log/nginx/api_access.log;
        }
    }
}
```

---

## 📁 Directory Structure

### Standard Installation

```
/etc/nginx/
├── nginx.conf              # Main configuration
├── conf.d/                 # Additional configs (auto-included)
│   ├── default.conf
│   └── custom.conf
├── sites-available/        # Available site configs
│   ├── example.com
│   └── api.example.com
├── sites-enabled/          # Enabled sites (symlinks)
│   └── example.com -> ../sites-available/example.com
├── snippets/               # Reusable config snippets
│   ├── ssl-params.conf
│   └── proxy-params.conf
└── modules-enabled/        # Enabled modules

/var/log/nginx/
├── access.log              # Access logs
└── error.log               # Error logs

/var/www/html/              # Default web root
└── index.html

/usr/share/nginx/html/      # Alternative web root
└── index.html
```

---

## 🔍 Variables

### Built-in Variables

```nginx
# Request variables
$request_method          # GET, POST, etc.
$request_uri             # Full original request URI
$uri                     # Current URI (may change during processing)
$args                    # Query string
$arg_name                # Specific query parameter

# Client variables
$remote_addr             # Client IP address
$remote_port             # Client port
$remote_user             # HTTP basic auth username

# Server variables
$server_name             # Server name from config
$server_addr             # Server IP address
$server_port             # Server port

# Connection variables
$connection              # Connection serial number
$connection_requests     # Requests in current connection

# HTTP headers
$http_host               # Host header
$http_user_agent         # User-Agent header
$http_referer            # Referer header
$http_cookie             # Cookie header

# Response variables
$status                  # Response status code
$body_bytes_sent         # Bytes sent to client (body only)
$bytes_sent              # Total bytes sent

# Time variables
$time_local              # Local time
$msec                    # Current time in milliseconds
$request_time            # Request processing time
```

### Custom Variables

```nginx
http {
    # Set custom variable
    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      close;
    }
    
    # Geo-based variable
    geo $country {
        default        US;
        192.168.1.0/24 UK;
        10.0.0.0/8     CA;
    }
    
    server {
        location / {
            # Use custom variable
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            
            # Set variable in location
            set $backend_server "backend1";
            proxy_pass http://$backend_server;
        }
    }
}
```

---

## 🚀 Performance Tuning

### Worker Optimization

```nginx
# /etc/nginx/nginx.conf
user nginx;
worker_processes auto;           # One per CPU core
worker_rlimit_nofile 65535;      # Max open files per worker

events {
    worker_connections 4096;     # Max connections per worker
    use epoll;                   # Linux: epoll, BSD: kqueue
    multi_accept on;             # Accept multiple connections at once
}
```

### Buffer Tuning

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
    
    # FastCGI buffers (for PHP)
    fastcgi_buffer_size 4k;
    fastcgi_buffers 8 4k;
}
```

### Connection Optimization

```nginx
http {
    # Keep-alive
    keepalive_timeout 65;
    keepalive_requests 100;
    
    # Upstream keep-alive
    upstream backend {
        server 192.168.1.10:8080;
        keepalive 32;  # Keep 32 idle connections to upstream
    }
    
    server {
        location / {
            proxy_pass http://backend;
            proxy_http_version 1.1;
            proxy_set_header Connection "";  # Clear Connection header
        }
    }
}
```

---

## 🛡️ Best Practices

### Configuration Organization

```nginx
# /etc/nginx/nginx.conf - Main config (minimal)
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}

# /etc/nginx/snippets/ssl-params.conf - Reusable SSL config
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers on;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;

# /etc/nginx/sites-available/example.com - Site config
server {
    listen 443 ssl http2;
    server_name example.com;
    
    include snippets/ssl-params.conf;
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    
    location / {
        root /var/www/example.com;
    }
}
```

### Testing Configuration

```bash
# Test configuration syntax
nginx -t

# Test and show configuration
nginx -T

# Reload configuration (graceful)
nginx -s reload

# Stop gracefully (finish current requests)
nginx -s quit

# Stop immediately
nginx -s stop
```

---

## ❓ Interview "Deep-Cut" Questions

1. **Explain Nginx's event-driven architecture and how it differs from Apache's process-based model.**
   - *Answer*: Nginx uses an asynchronous, event-driven architecture where a small number of worker processes handle thousands of connections using non-blocking I/O. Apache's prefork MPM creates a new process for each connection, consuming more memory. Nginx can handle 10,000+ connections with 4 workers, while Apache would need 10,000 processes.

2. **What is the difference between `proxy_pass http://backend` and `proxy_pass http://backend/`?**
   - *Answer*: Without trailing slash, Nginx appends the full URI. With trailing slash, it replaces the location prefix. Example: `location /api { proxy_pass http://backend; }` → `/api/users` becomes `http://backend/api/users`. With slash: `proxy_pass http://backend/;` → `/api/users` becomes `http://backend/users`.

3. **How does Nginx handle worker process crashes?**
   - *Answer*: The master process monitors workers. If a worker crashes, the master immediately spawns a new one. Existing connections to the crashed worker are lost, but new connections are distributed to healthy workers. This is why proper error logging and monitoring are critical.

4. **Explain the difference between `return` and `rewrite` directives.**
   - *Answer*: `return` immediately stops processing and sends a response (faster). `rewrite` modifies the URI and continues processing. Use `return` for simple redirects (301/302), `rewrite` when you need to change the URI and continue to other directives.

5. **What is the purpose of `worker_cpu_affinity` and when should you use it?**
   - *Answer*: Binds worker processes to specific CPU cores to improve CPU cache efficiency and reduce context switching. Use in high-performance scenarios where you want to prevent workers from migrating between cores. Example: `worker_cpu_affinity auto;` automatically binds workers to cores.

---

**Next Step**: [Nginx Configuration Patterns →](./nginx-configuration-ref.md)
