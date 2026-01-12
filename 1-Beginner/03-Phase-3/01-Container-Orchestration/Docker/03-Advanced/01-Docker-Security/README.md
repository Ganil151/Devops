# Advanced Docker Security

Securing Docker is not a one-time task; it's a layered approach that involves securing the host, the images, and the runtime. This module covers enterprise-grade security practices for production environments.

---

## 🛡️ 1. The Principle of Least Privilege

### Rootless Docker
By default, the Docker daemon runs with root privileges. **Rootless Mode** allows you to run the daemon and containers as a non-privileged user, significantly reducing the impact of a container breakout.

> [!NOTE]
> Even if a container is compromised, the attacker only gains the privileges of the non-root user on the host, not the entire machine.

### Non-Root Users in Dockerfiles
Always specify a non-root user in your `Dockerfile` to prevent the application from running as root inside the container.

```dockerfile
# GOOD: Using a non-root user
FROM python:3.12-alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY . .
RUN chown -R appuser:appgroup /app
USER appuser
CMD ["python", "app.py"]
```

---

## 🔍 2. Vulnerability Scanning

### Image Scanning with Trivy
Before pushing to a registry, always scan your images for vulnerabilities (CVEs). [Trivy](https://github.com/aquasecurity/trivy) is the industry standard for fast and comprehensive scanning.

```bash
# Scan a local image
trivy image myapp:latest

# Scan for high and critical vulnerabilities only
trivy image --severity HIGH,CRITICAL myapp:latest
```

---

## 🏗️ 3. Runtime Security

### Linux Capabilities
Docker allows you to drop or add specific kernel capabilities. Most containers don't need all default capabilities.

```yaml
# Drop all capabilities and only add what's needed (e.g., NET_BIND_SERVICE)
services:
  web:
    image: nginx
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
```

### Seccomp Profiles
Seccomp (Secure Computing mode) limits the system calls a container can make to the Linux kernel. Docker uses a default profile that blocks ~44 dangerous syscalls out of 300+.

---

## 📏 4. Compliance & Benchmarking

### CIS Docker Benchmark
The Center for Internet Security (CIS) provides a baseline for securing Docker installations. Use the **docker-bench-security** script to audit your host against these standards.

```bash
docker run --rm --net host --pid host --userns host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    vuls/docker-bench-security
```

---

## 💡 Top Security Best Practices

1.  **Keep Images Small:** Use `alpine` or `distroless` images to reduce the attack surface.
2.  **Enable Content Trust:** Set `export DOCKER_CONTENT_TRUST=1` to ensure you only pull signed images.
3.  **Read-Only Filesystem:** Whenever possible, run your container with a read-only root filesystem to prevent attackers from writing malicious scripts.
    ```bash
    docker run --read-only myapp:latest
    ```
4.  **No Secrets in Images:** Never include API keys or passwords in environment variables or Dockerfiles. Use Docker Secrets or a Vault.

---

## ✅ Knowledge Check
- [ ] Can you explain why running as root is a security risk?
- [ ] Have you integrated `trivy` into your CI/CD pipeline?
- [ ] Do you know how to drop Linux capabilities in a `compose.yaml`?

---
*Next Step: Optimize your container performance in **[Resource Management](../02-Resource-Management/)**.*
