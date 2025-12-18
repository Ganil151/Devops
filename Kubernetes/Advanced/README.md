# Advanced Level: Production, Security & Scaling

Welcome to the deep end. The Advanced level covers concepts required for operating production-grade clusters, securing them, and managing complex stateful applications.

## 🎯 Learning Objectives
- Manage stateful applications with **StatefulSets**.
- secure the cluster with **RBAC** and **NetworkPolicies**.
- Understand the **Control Plane** internals.
- Implement **Autoscaling** (HPA, VPA).
- Manage cluster networking with **CNI**.

## 📂 Directory Structure

### 1. [Control Plane Deep Dive](Control-Plane/)
Understand the inner workings.
- **API Server**, **Scheduler**, **Controller Manager**, **ETCD**.

### 2. [Complex Workloads](StatefulSets/)
- **StatefulSets**: For databases and distributed systems requiring stable identities.
- **DaemonSets**: Run a copy of a pod on every node (logs, monitoring).

### 3. [Security](RBAC/)
- **RBAC**: Role-Based Access Control. Who can do what.
- **NetworkPolicies**: Firewall rules for Pods.
- **Admission Controllers**: Intercept requests to the API server.
- **Certificates**: TLS management.

### 4. [Autoscaling](Autoscaling/)
- **HPA**: Scale pods based on CPU/Memory.
- **VPA**: Adjust pod resource requests automatically.
- **PDB**: Pod Disruption Budgets for availability.

### 5. [Networking Deep Dive](CNI/)
- **CNI**: Container Network Interface plugins.
- **Service Mesh**: Advanced traffic management (Istio, Linkerd).

### 6. [Enterprise Storage](CSI/)
- **CSI**: Container Storage Interface.
- **Backup & Restore**: Disaster recovery strategies.

### 7. [Cloud Specific (EKS)](EKS/)
- Amazon Elastic Kubernetes Service specific configurations and Terraform code.

### 8. [Advanced Scheduling](Scheduling/)
- **Taints & Tolerations**: Repel pods from nodes.
- **Affinity**: Attract pods to nodes or other pods.

### 9. [GitOps](GitOps/)
- **ArgoCD**: Pull-based deployment.
### 10. [Certificates & TLS](Certificates/)
- **PKI**: Managing keys and certs.
- **cert-manager**: Automating Issuers and Certificates.

### 11. [Compliance & Policy](Compliance/)
- **OPA/Gatekeeper**: Policy as Code.
- **Pod Security Standards**: Enforcing baseline/restricted profiles.

### 12. [Service Mesh](ServiceMesh/)
- **Istio/Linkerd**: Traffic management and mTLS.
- **Sidecars**: Proxy architecture.

## 🔧 Advanced Operations
- **Helm**: Package management for Kubernetes.
- **Operators**: Custom controllers for complex apps.
- **Custom Resource Definitions (CRDs)**: Extending the API.

## ⚠️ Best Practices
- **Least Privilege**: Lock down RBAC and Network Policies.
- **Resource Limits**: Always set requests and limits to avoid noisy neighbors.
- **GitOps**: Manage cluster state via Git (ArgoCD, Flux).

[Back to Intermediate](../Intermediate/README.md) | [Back to Root](../README.md)
