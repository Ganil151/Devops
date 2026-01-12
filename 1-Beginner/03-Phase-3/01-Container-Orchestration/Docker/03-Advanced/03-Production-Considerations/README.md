# Production Considerations for Docker

Running containers in production requires a different mindset than development. It's about stability, observability, and long-term maintainability. This module covers the essential "Day 2" operations for Docker.

---

## 📝 1. Logging Drivers

By default, Docker uses the `json-file` driver, which stores logs on the host. In production, you should ship logs to a centralized system (e.g., ELK stack, Splunk, or CloudWatch).

### Configuring a Logging Driver
You can set this globally in `daemon.json` or per container in `compose.yaml`.

```yaml
services:
  app:
    image: myapp:prod
    logging:
      driver: "syslog"
      options:
        syslog-address: "tcp://192.168.0.42:514"
        tag: "prod-app"
```

---

## 🌍 2. Multi-Architecture Builds (Docker Buildx)

Production environments often use a mix of x86 (Intel/AMD) and ARM (Apple Silicon, AWS Graviton) processors. **Buildx** allows you to build a single image tag that works on multiple architectures.

```bash
# Create a builder
docker buildx create --use

# Build and push a multi-arch image
docker buildx build --platform linux/amd64,linux/arm64 -t myrepo/myapp:latest --push .
```

---

## 🏥 3. Advanced Health Checks

A basic health check only checks if the process is running. A production health check should verify that the application is actually capable of serving traffic.

```yaml
services:
  web:
    image: myapp:prod
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

---

## 🧹 4. Garbage Collection (Pruning)

Over time, unused images, dangling volumes, and stopped containers consume significant disk space.

### Automatic Pruning
You can set up a cron job to prune unused resources periodically.

```bash
# Remove all unused containers, networks, and images (not just dangling ones)
docker system prune -a --volumes -f
```

---

## 🚀 5. Update Strategies

### Zero-Downtime Updates (Docker Compose)
While Docker Compose doesn't have native "Rolling Updates" like Kubernetes, you can achieve it using the `--scale` and `depends_on` flags combined with a reverse proxy like Nginx.

1.  Start a new container.
2.  Wait for it to be healthy.
3.  Update the Nginx proxy to point to the new container.
4.  Remove the old container.

---

## ✅ Knowledge Check
- [ ] Why is the default `json-file` logging driver risky for production?
- [ ] How do you build an image for both Intel and M1/M2 Mac users?
- [ ] How do you prevent disk space issues on your Docker servers?

---
*Next Step: Finalize your roadmap in the **[Global Index](DevOps%20Foundations.md)**.*
