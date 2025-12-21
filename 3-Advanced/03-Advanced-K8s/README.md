# Advanced Kubernetes: Extensibility & Service Mesh

Kubernetes is just the foundation. This module explores how to extend and manage K8s for complex, high-performance, and secure enterprise applications.

---

## 1. Extending the API (Operators & CRDs)

Kubernetes is designed to be extensible. You can define your own resources (CRDs) and controllers (Operators) to manage them.
- **Custom Resource Definitions (CRDs)**: Expanding the K8s vocabulary (e.g., adding a `Database` resource).
- **Operators**: Software that encapsulates human operational knowledge to manage complex, stateful applications automatically.

---

## 2. Service Mesh (Istio / Linkerd)

As microservices grow, managing communication between them becomes difficult. A Service Mesh provides a dedicated infrastructure layer for:
- **Traffic Management**: Blue-green deployments, canary rollouts, and circuit breaking.
- **Security**: Mutual TLS (mTLS) for all service-to-service communication by default.
- **Observability**: Automatic tracing and metrics for all network traffic without changing app code.

---

## 3. Core Modules

### ☸️ [Operators & Internals](./03-Advanced-K8s/README.md)
Deep dive into Admission Controllers, Scheduler customization, and the K8s API.

### 🕸️ [Service Mesh Deep Dive](./03-Advanced-K8s/Service-Mesh/)
Mastering Istio and Linkerd for secure, observable networking.

---

## 4. Best Practices
1. **Prefer Managed Addons**: Use managed Service Mesh (like AWS App Mesh) if possible to reduce operational overhead.
2. **Admission Control**: Use Validating Webhooks to enforce security and compliance rules at the cluster boundary.
3. **Cluster Federation**: Building strategies for managing multiple clusters across different regions or clouds.

---
**Observability**: Correlate your Mesh traffic with application logic in the [Observability Module](../02-Observability/README.md).
