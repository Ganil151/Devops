# Nginx Best Practices Reference

## 1. Overview

A "working" Nginx configuration is not necessarily a "production-ready" one. This guide outlines the critical security, structural, and optimization patterns required for a robust DevOps infrastructure.

---

## 2. Security Hardening

Security is not an afterthought; it is the default configuration state.

### Least Privilege

Never run workers as root. Ensure the `user` directive is set to a low-privilege account.

```nginx
# /etc/nginx/nginx.conf
user nginx;  # or www-data
```

### Hide Server Version (Security by Obscurity)

Prevent attackers from identifying specific vulnerabilities associated with your Nginx version.

```nginx
http {
    server_tokens off;
}
```

### Secure Headers

Inject headers to protect clients from XSS, Clickjacking, and sniffing attacks.

```nginx
server {
    # Prevent clickjacking (site cannot be embedded in an iframe)
    add_header X-Frame-Options "SAMEORIGIN";

    # Enable Cross-Site Scripting (XSS) filter in browser
    add_header X-XSS-Protection "1; mode=block";

    # Prevent MIME-type sniffing
    add_header X-Content-Type-Options "nosniff";

    # HTTP Strict Transport Security (HSTS) - Force HTTPS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
}
```

---

## 3. Structural Configuration (Modular Design)

Avoid the "Monolithic Config" anti-pattern. Do not put all server blocks in `nginx.conf`.

### The `conf.d` Pattern

Use the `include` directive to load configurations from separate files. This makes automation (Ansible/Terraform) easier.

**Main Config (`nginx.conf`):**

```nginx
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # Load modular configurations
    include /etc/nginx/conf.d/*.conf;
}
```

**Site Config (`/etc/nginx/conf.d/app1.conf`):**

```nginx
server {
    listen 80;
    server_name app1.example.com;
    # ... specific logic for app1
}
```

---

## 4. Performance Optimization

Tune Nginx to utilize the underlying OS capabilities efficiently.

### Worker Connections

Increase the limit of simultaneous connections per worker.

```nginx
events {
    # Default is often 1024.
    # Max Clients = worker_processes * worker_connections
    worker_connections 4096;

    # Accept as many connections as possible
    multi_accept on;
}
```

_Note: Ensure your OS `ulimit -n` is high enough to support this._

### High-Speed I/O Directives

```nginx
http {
    # Copies data between file descriptor and socket in kernel space
    # (Zero Copy). Drastically reduces CPU usage for static files.
    sendfile on;

    # Sends headers in one packet rather than one by one.
    tcp_nopush on;

    # Disables Nagle's algorithm. Sends data immediately.
    # Good for real-time apps, bad for bandwidth efficiency.
    tcp_nodelay on;
}
```

---

## 5. Why for DevOps?

1.  **Automation Friendly:** Modular config structures (`conf.d`) allow CI/CD pipelines to deploy specific app configs without touching the core `nginx.conf`.
2.  **Compliance:** Implementing secure headers and hiding versions are standard requirements for SOC2 and PCI-DSS audits.
3.  **Scalability:** Tuning `worker_connections` and `sendfile` ensures the load balancer doesn't become the bottleneck as the application scales.

---

## 6. Interview Questions

1.  **Q: Why should you disable `server_tokens` in Nginx?**
    - **A:** To prevent attackers from knowing the exact version of Nginx running, which could help them exploit known vulnerabilities specific to that version.

2.  **Q: What is the purpose of the `sendfile` directive?**
    - **A:** It enables the use of the `sendfile()` system call, which copies data directly from one file descriptor to another within the kernel, bypassing user space buffers and saving CPU cycles.

3.  **Q: How do you organize Nginx configuration for multiple microservices?**
    - **A:** By using the `include` directive to load separate `.conf` files from a directory like `/etc/nginx/conf.d/`, keeping each service's configuration isolated and manageable.

4.  **Q: What does `worker_connections` determine?**
    - **A:** It sets the maximum number of simultaneous connections that a single worker process can open. This includes client connections and connections to upstream servers.

5.  **Q: Explain the difference between `tcp_nopush` and `tcp_nodelay`.**
    - **A:** `tcp_nopush` optimizes throughput by sending full packets (useful for file transfers), while `tcp_nodelay` optimizes latency by disabling Nagle's algorithm to send data immediately (useful for interactive apps).

---

**Related References:**

- Nginx Architecture
- Nginx Security & Performance
