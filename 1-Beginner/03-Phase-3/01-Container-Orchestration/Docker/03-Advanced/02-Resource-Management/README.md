# Docker Resource Management

In a production environment, you must ensure that no single container can consume all of the host's resources. Docker provides powerful mechanisms to throttle CPU, memory, and I/O usage.

---

## 🧠 1. Memory Constraints

### Hard Limits
A hard limit prevents the container from using more than a specific amount of RAM. If the container hits this limit, the Linux **OOM (Out Of Memory) Killer** may terminate the process.

```bash
# Run with 512MB hard limit
docker run -m 512m myapp:latest
```

### Soft Limits (Reservations)
A soft limit ensures the container gets at least its reserved memory when the host is low on resources, but allows it to use more if capacity exists.

```yaml
# Docker Compose example
services:
  app:
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 128M
```

---

## ⚡ 2. CPU Constraints

### CPU Shares (Relative Weight)
By default, all containers have the same priority. You can adjust the weight of a container using `--cpu-shares`.

### CPU Quotas (Hard Throttling)
You can limit a container to a specific percentage of a CPU core or multiple cores.

```bash
# Limit to half of a single CPU core (0.5 CPUs)
docker run --cpus="0.5" myapp:latest
```

---

## 🚨 3. The OOM Killer

When the system runs out of memory, the Linux kernel starts killing processes to save the host. Docker allows you to adjust the **OOM Score** of a container to make it more or less likely to be killed.

> [!CAUTION]
> If you don't set limits, a single memory leak in one container can cause the host to crash, affecting all other services.

---

## 📊 4. Monitoring Resources

### Docker Stats
To see real-time resource usage of your running containers:

```bash
docker stats
```

### cAdvisor
For production monitoring, **cAdvisor** (Container Advisor) is a sidecar container that exports resource usage metrics to Prometheus for long-term graphing.

---

## 🛠️ Performance Tuning (Sysctls)
Advanced users can tune kernel parameters (sysctls) inside a container. Note that this often requires `--privileged` or specific capabilities.

```yaml
services:
  web:
    sysctls:
      net.core.somaxconn: 1024
      net.ipv4.tcp_syncookies: 0
```

---

## ✅ Knowledge Check
- [ ] What happens when a container exceeds its `-m` limit?
- [ ] What is the difference between a `limit` and a `reservation`?
- [ ] How do you monitor memory usage of a specific container?

---
*Next Step: Scale your operations in **[Production Considerations](../03-Production-Considerations/)**.*
