# 🐳 Container & Orchestration: Definition of Done Checklist

> **"A container is a promise of consistency. Orchestration is the delivery of that promise at scale."**

---

## 1. Image Optimization & Security

- [ ] **Implementation of Multi-Stage Builds**
    - **The "Why"**: Significantly reduces the final image size and attack surface by excluding build-time tools (compilers, git) from the production image.
    - **Verification**: Compare the size of a single-stage vs. multi-stage image.
    - **Command**: `docker images` - look for small footprints (e.g., <100MB for Go apps).

- [ ] **Non-Root User Configuration**
    - **The "Why"**: Mitigates the impact of a container breakout by ensuring the application process does not have administrative privileges on the host.
    - **Verification**: Check the Dockerfile for the `USER` instruction and verify the process UID at runtime.
    - **Command**: `docker exec <container_id> whoami` or `kubectl exec -it <pod> -- id`.

---

## 2. Kubernetes Manifests & Resource Strategy

- [ ] **Resource Requests & Limits (CPU/Memory)**
    - **The "Why"**: Prevents "Noisy Neighbor" issues and ensures the K8s scheduler can place pods effectively without starving others.
    - **Verification**: Check the `resources` section of the deployment manifest.
    - **Command**: `kubectl describe pod <pod_name> | grep -A 5 "Limits"`.

- [ ] **Configured Liveness & Readiness Probes**
    - **The "Why"**: Enables high availability by allowing K8s to restart unhealthy pods and prevent routing traffic to pods that are still initializing.
    - **Verification**: Check for `livenessProbe` and `readinessProbe` in the manifest.
    - **Command**: `kubectl get pods -w` - observe restarts if the app becomes unhealthy.

---

## 3. Storage & Connectivity

- [ ] **Externalized Configuration (ConfigMaps/Secrets)**
    - **The "Why"**: Avoids rebuilding images when application configuration changes, maintaining the "Build Once, Deploy Many" principle.
    - **Verification**: Verify that sensitive data is pulled from K8s Secrets and config from ConfigMaps.
    - **Command**: `kubectl get configmaps` and `kubectl get secrets`.

- [ ] **Network Policy Implementation**
    - **The "Why"**: Enforces Zero-Trust within the cluster by restricting which pods can communicate with each other.
    - **Verification**: Verify a `NetworkPolicy` object exists restricting ingress to the database.
    - **Command**: `kubectl get netpol`.

---

## ❓ Professional Validation (Interview Readiness)

1. **Q: What is the difference between a Liveness and a Readiness probe?**
   - *A: Liveness tells K8s if the pod is alive (if it fails, K8s kills/restarts it). Readiness tells K8s if the pod is ready to serve traffic (if it fails, K8s removes it from the Service endpoint).*

2. **Q: Why should you avoid using the 'latest' tag for container images?**
   - *A: It makes the deployment non-deterministic. You cannot guarantee which version of the code is running, which makes rollbacks nearly impossible.*
