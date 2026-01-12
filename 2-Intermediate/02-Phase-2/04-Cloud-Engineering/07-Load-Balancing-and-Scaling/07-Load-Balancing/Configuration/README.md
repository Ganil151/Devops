# Load Balancer Configuration

Practical configuration examples and templates for various load balancing scenarios.

## NGINX Load Balancer

### Basic HTTP Load Balancing
```nginx
# /etc/nginx/nginx.conf
upstream backend {
    server 192.168.1.10:80 weight=3;
    server 192.168.1.11:80 weight=2;
    server 192.168.1.12:80 weight=1;
    server 192.168.1.13:80 backup;
}

server {
    listen 80;
    server_name example.com;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### HTTPS with SSL Termination
```nginx
upstream backend_ssl {
    server 192.168.1.10:80;
    server 192.168.1.11:80;
    server 192.168.1.12:80;
}

server {
    listen 443 ssl http2;
    server_name example.com;
    
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    
    location / {
        proxy_pass http://backend_ssl;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}
```

## HAProxy Configuration

### Basic Load Balancing
```bash
# /etc/haproxy/haproxy.cfg
global
    daemon
    maxconn 4096
    log stdout local0

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
    option httplog

frontend web_frontend
    bind *:80
    bind *:443 ssl crt /etc/ssl/certs/example.com.pem
    redirect scheme https if !{ ssl_fc }
    default_backend web_servers

backend web_servers
    balance roundrobin
    option httpchk GET /health
    server web1 192.168.1.10:80 check weight 100
    server web2 192.168.1.11:80 check weight 100
    server web3 192.168.1.12:80 check weight 50 backup
```

### Advanced HAProxy with Sticky Sessions
```bash
backend web_servers_sticky
    balance source
    hash-type consistent
    option httpchk GET /health
    cookie SERVERID insert indirect nocache
    server web1 192.168.1.10:80 check cookie web1
    server web2 192.168.1.11:80 check cookie web2
    server web3 192.168.1.12:80 check cookie web3
```

## Kubernetes Load Balancing

### Service Load Balancer
```yaml
# service-loadbalancer.yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
    - name: http
      port: 80
      targetPort: 8080
      protocol: TCP
    - name: https
      port: 443
      targetPort: 8443
      protocol: TCP
```

### Ingress Controller
```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/use-regex: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
    - hosts:
        - example.com
        - api.example.com
      secretName: example-tls
  rules:
    - host: example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-service
                port:
                  number: 80
    - host: api.example.com
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 80
```

## Docker Compose Load Balancing

### NGINX + Multiple App Instances
```yaml
# docker-compose.yml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl/certs
    depends_on:
      - app1
      - app2
      - app3

  app1:
    image: myapp:latest
    environment:
      - SERVER_ID=app1
    expose:
      - "8080"

  app2:
    image: myapp:latest
    environment:
      - SERVER_ID=app2
    expose:
      - "8080"

  app3:
    image: myapp:latest
    environment:
      - SERVER_ID=app3
    expose:
      - "8080"
```

## Health Check Configuration

### Advanced Health Checks
```nginx
# NGINX health check with custom logic
upstream backend_health {
    server 192.168.1.10:80 max_fails=3 fail_timeout=30s;
    server 192.168.1.11:80 max_fails=3 fail_timeout=30s;
    server 192.168.1.12:80 max_fails=3 fail_timeout=30s;
}

location /health {
    access_log off;
    return 200 "healthy\n";
    add_header Content-Type text/plain;
}
```

### HAProxy Health Checks
```bash
backend web_servers_health
    option httpchk GET /health HTTP/1.1\r\nHost:\ example.com
    http-check expect status 200
    http-check expect string "healthy"
    server web1 192.168.1.10:80 check inter 10s rise 2 fall 3
    server web2 192.168.1.11:80 check inter 10s rise 2 fall 3
```

This guide provides practical load balancer configuration examples for various platforms and scenarios.