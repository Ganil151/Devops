# Health Checks and Probing

Health checks are the "pulse" of your application. They tell orchestrators (like Kubernetes) if a container is alive and ready to serve traffic.

---

## 🏥 1. Liveness vs Readiness Probes

### Liveness Probe
- **Purpose**: "Are you alive?"
- **Action**: If it fails, Kubernetes kills the container and restarts it.
- **Example**: Is the main process still responding? Is there a deadlock?

### Readiness Probe
- **Purpose**: "Are you ready for traffic?"
- **Action**: If it fails, Kubernetes stops sending traffic to this pod. It does *not* kill the pod.
- **Example**: Is the database connection established? Is the cache warmed up?

---

## 🛠️ 2. Types of Checks
1. **HTTP Get**: Checks if an endpoint (like `/healthz`) returns a 2xx or 3xx status code.
2. **TCP Socket**: Checks if a specific port is open.
3. **Exec Command**: Runs a script inside the container. If it exits with 0, it's healthy.

---

## 🌐 3. Synthetic Monitoring
Creating "fake" users that regularly test your critical business flows (e.g., every 5 minutes, a bot tries to log in and add an item to the cart).
- **Goal**: Detect user-facing issues before real customers do.

---

## 💡 Best Practices
- **Do not check dependencies in Liveness probes**: If your DB is down and you check it in a liveness probe, K8s will restart all your apps, making the situation worse (Cascading Failure).
- **Keep it lightweight**: Health check endpoints should not perform heavy calculations.
- **Differentiate probes**: Use different endpoints for liveness (internal health) and readiness (external connectivity).
