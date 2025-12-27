# NGINX Reverse Proxy and SSL with Let's Encrypt

NGINX is often used as a **Reverse Proxy** in front of application containers. It handles SSL termination, load balancing, and static file serving, keeping your application code simple and secure.

## 1. NGINX as a Reverse Proxy

In a Docker Compose setup, NGINX can route traffic to backend services by their service names.

### Sample `nginx.conf`
```nginx
events {
    worker_connections 1024;
}

http {
    upstream backend_app {
        server flask_app:8080;
    }

    server {
        listen 80;
        server_name myapp.example.com;

        location / {
            proxy_pass http://backend_app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
```

---

## 2. Securing with Let's Encrypt (Certbot)

To get free SSL certificates from Let's Encrypt, we use the `certbot` image. The standard pattern is a "Sidecar" approach where Certbot handles the certificate challenges and renewals.

### Docker Compose Workflow
The most robust way to do this in production is using the **nginx-proxy** pattern or a manual Certbot configuration like below.

#### Step A: Configure NGINX for the HTTP Challenge
NGINX must serve the `.well-known/acme-challenge/` directory to prove you own the domain.

```nginx
server {
    listen 80;
    server_name myapp.example.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}
```

#### Step B: Integrate Certbot in `compose.yaml`
```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - certbot-etc:/etc/letsencrypt
      - certbot-var:/var/lib/letsencrypt
      - web-root:/var/www/certbot:ro

  certbot:
    image: certbot/certbot
    volumes:
      - certbot-etc:/etc/letsencrypt
      - certbot-var:/var/lib/letsencrypt
      - web-root:/var/www/certbot
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'"

volumes:
  certbot-etc:
  certbot-var:
  web-root:
```

---

## 3. Automatic Renewal
By setting the `entrypoint` in the `certbot` service as shown above, the container will stay running and attempt to renew your certificates every 12 hours. Since NGINX and Certbot share the same volumes, NGINX will pick up the new certificates (usually requires a `nginx -s reload`).

---

## 4. Best Practices
- ✅ **Use Alpine**: Keep your NGINX image small.
- ✅ **DHParam**: Generate a Strong Diffie-Hellman group for extra security.
- ✅ **HSTS**: Enable HTTP Strict Transport Security in your NGINX config.
- ✅ **Logging**: Map `/var/log/nginx` to a volume for log analysis.

---

**[Back to Home](../../README.md)**
