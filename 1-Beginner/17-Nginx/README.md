# Module 17: Nginx Web Server

Nginx (pronounced "Engine-X") is a high-performance HTTP web server, reverse proxy, and Load Balancer. It is known for its stability, rich feature set, simple configuration, and low resource consumption.

---

## 🎯 Learning Objectives

- Understand the Event-Driven Architecture of Nginx.
- Install Nginx on Linux and Docker.
- Master the `nginx.conf` file structure (Contexts and Directives).
- Configure Nginx as a Static Web Server.
- Set up a Reverse Proxy and Load Balancer.
- Implement Basic Security (SSL/TLS, Rate Limiting).

---

## 🏗️ Architecture: Why Nginx?

### The C10K Problem
In the early 2000s, web servers like Apache used a **Process/Thread-based** model. Every client connection spawned a new thread. Scaling to 10,000 concurrent connections ("C10K") required massive memory.

### The Event-Driven Model
Nginx uses an **Asynchronous, Event-Driven** architecture.
- **Master Process**: Reads config, binds ports, manages workers.
- **Worker Processes**: Handle thousands of connections **non-blocking** using a single thread (epoll/kqueue).
- **Result**: Nginx can handle 10,000+ connections with just a few MB of RAM.

---

## 📦 Installation

### 🐧 Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install nginx
```

**Service Management**:
```bash
sudo systemctl start nginx    # Start service
sudo systemctl enable nginx   # Enable on boot
sudo systemctl status nginx   # Check status
```

### 🐳 Docker

Run a simple Nginx container serving default content:

```bash
docker run -d -p 80:80 --name my-nginx nginx:alpine
```

Bind mount your own content:
```bash
docker run -d -p 80:80 \
  -v $(pwd)/html:/usr/share/nginx/html \
  --name my-nginx nginx:alpine
```

---

## ⚙️ Configuration Hierarchy

The main configuration file is usually at `/etc/nginx/nginx.conf`.

### Directory Structure (Debian/Ubuntu style)
- **`/etc/nginx/nginx.conf`**: The root configuration.
- **`/etc/nginx/conf.d/*.conf`**: Global HTTP settings.
- **`/etc/nginx/sites-available/`**: Config files for virtual hosts (not valid yet).
- **`/etc/nginx/sites-enabled/`**: Symlinks to `sites-available` (active configs).
- **`/var/log/nginx/`**: Access and Error logs.

### Contexts & Directives
Nginx config is a tree of **Contexts** (blocks) containing **Directives** (key-value pairs).

```nginx
# 'main' context (Global settings)
user www-data;
worker_processes auto;

events {
    # 'events' context
    worker_connections 1024;
}

http {
    # 'http' context (All HTTP handling)
    include       mime.types;
    default_type  application/octet-stream;
    
    server {
        # 'server' context (Specific Virtual Host)
        listen 80;
        server_name example.com;
        
        location / {
            # 'location' context (URL matching)
            root /var/www/html;
            index index.html;
        }
    }
}
```

---

## 🚀 Core Use Cases

### 1. Static Web Server
Serve HTML, CSS, and JS files efficiently.

```nginx
server {
    listen 80;
    server_name mywebsite.com;
    
    location / {
        root /var/www/mywebsite;
        index index.html;
    }
    
    location /images/ {
        root /var/www/media;
        autoindex on; # List files
    }
}
```

### 2. Reverse Proxy
Forward requests to an application server (e.g., Node.js, Python, Java). This hides your backend and adds security/performance.

```nginx
server {
    listen 80;
    server_name app.example.com;

    location / {
        proxy_pass http://localhost:3000; # Forward to Node.js app
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 3. Load Balancer
Distribute traffic across multiple backend servers.

```nginx
upstream backend_servers {
    server 10.0.0.1:3000 weight=3; # Receives 3x traffic
    server 10.0.0.2:3000;
    server 10.0.0.3:3000 backup;   # Only used if others fail
}

server {
    listen 80;
    location / {
        proxy_pass http://backend_servers;
    }
}
```

---

## 🛡️ Security Best Practices

### SSL/TLS Termination (HTTPS)
Using Let's Encrypt (Certbot) is the standard, but here is the manual config:

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;

    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    
    # Modern SSL Protocols
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name example.com;
    return 301 https://$host$request_uri;
}
```

### Rate Limiting
Protect against DDoS and Brute Force.

```nginx
# Define limit zone in 'http' context
limit_req_zone $binary_remote_addr zone=mylimit:10m rate=10r/s;

server {
    location /login {
        # Apply limit
        limit_req zone=mylimit burst=20 nodelay;
        proxy_pass http://localhost:3000;
    }
}
```

---

## ⚡ Performance Optimization

- **Gzip Compression**: Reduce file size before sending.
    ```nginx
    gzip on;
    gzip_types text/plain application/json text/css application/javascript;
    ```
- **Caching**: Cache static files in browser.
    ```nginx
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
    ```

---

## 🧪 DevOps Labs

### Lab 1: Deploy a Reverse Proxy
**Goal**: Run a Python web server on port 8000 and expose it via Nginx on port 80.
1. Create `python -m http.server 8000`.
2. Configure Nginx `proxy_pass http://127.0.0.1:8000`.
3. Access via `http://localhost`.

### Lab 2: Path-Based Routing
**Goal**: Route `/api` to one backend and `/` to a static site.
1. `location / { root /var/www/html; }`
2. `location /api { proxy_pass http://localhost:5000; }`

---

## 🧠 Knowledge Quiz

**1. What is the main advantage of Nginx's architecture?**
- A) It uses one thread per connection
- B) It uses an asynchronous event-driven model
- C) It is written in Java
- D) It only supports static files

**2. Which context is used to define a virtual host?**
- A) `http`
- B) `global`
- C) `server`
- D) `location`

**3. What directive is used to forward traffic to a backend app?**
- A) `return`
- B) `proxy_pass`
- C) `root`
- D) `rewrite`

---

**Next Step**: Continue to [Module 18: Advanced Nginx or DevOps Projects](DevOps%20Foundations.md).
