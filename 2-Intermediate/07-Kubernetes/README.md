# Kubernetes (K8s) Orchestration Guide

Kubernetes is the industry-standard system for automating deployment, scaling, and management of containerized applications. It has become the "OS of the Cloud."

---

## 🗺️ The Kubernetes Learning Path

Follow these modules in order to master container orchestration:

1.  **[01-Cluster-Architecture](./01-Cluster-Architecture/README.md)**: Master the Control Plane and Worker Node relationships.
2.  **[02-Kubectl-Basics](./02-Kubectl-Basics/README.md)**: Essential commands for inspecting and managing resources.
3.  **[03-Pods-and-Nodes](./03-Pods-and-Nodes/README.md)**: The foundational units of compute in K8s.
4.  **[04-Deployments-and-Scaling](./04-Deployments-and-Scaling/README.md)**: Managing stateless applications and rolling updates.
5.  **[05-Services-and-Networking](./05-Services-and-Networking/README.md)**: Exposing applications and service discovery (DNS).
6.  **[06-Ingress-Controllers](./06-Ingress-Controllers/README.md)**: Layer 7 routing and SSL termination.
7.  **[07-ConfigMaps-and-Secrets](./07-ConfigMaps-and-Secrets/README.md)**: Decoupling configuration from containers.
8.  **[08-Persistence-and-Storage](./08-Persistence-and-Storage/README.md)**: Handling stateful data with PVs, PVCs, and StorageClasses.
9.  **[09-StatefulSets-and-Jobs](./09-StatefulSets-and-Jobs/README.md)**: Databases, batch processes, and scheduled tasks.
10. **[10-Managed-Kubernetes-EKS](./10-Managed-Kubernetes-EKS/README.md)**: Running Kubernetes in the AWS Cloud.
11. **[11-Cluster-Administration](./11-Cluster-Administration/README.md)**: Namespaces, RBAC, and Security Contexts.
12. **[12-Interview-Questions-and-Quizzes](./12-Interview-Questions-and-Quizzes/README.md)**: Test your knowledge and prepare for job screenings.
13. **[13-Real-Life-Scenarios](./13-Real-Life-Scenarios/README.md)**: Practical troubleshooting and architectural challenges.
14. **[📺 YouTube Lessons](./Youtube_Lessons.md)**: Curated video tutorials for visual learning.

---

## 🏗️ 1. Core Architecture
- **Control Plane**: The brain. It contains `kube-api`, `etcd`, and the `scheduler`.
- **Worker Nodes**: Where the work happens. Each node runs `kubelet` and `kube-proxy`.
- **Desired State**: You tell K8s what you want (YAML), and it works 24/7 to make it happen.

---

## 🛡️ Best Practices
- **Declarative Files**: Always use `kubectl apply -f` (Infrastructure as Code).
- **Resources**: Always set CPU/RAM requests and limits.
- **Health Checks**: Always implement Liveness and Readiness probes.
- **Isolation**: Use Namespaces to separate teams and environments.

---

## ✅ Knowledge Check
- [x] Install `kubectl` and a local cluster (`minikube`/`kind`).
- [x] Deploy an application and expose it via a Service.
- [x] Perform a zero-downtime rolling update.
- [x] Use `ConfigMaps` to pass environment variables.
- [x] Troubleshoot a failing pod using `describe` and `logs`.
- [x] Pass the 20-Question assessment in module 12.

---

## 🏆 Related Certifications
- **Certified Kubernetes Administrator (CKA)**
- **Certified Kubernetes Application Developer (CKAD)**

---

## 🔗 Next Steps
- **[Helm Charts](../08-Helm/)** - Package your K8s apps for reuse.
- **[Observability Foundations](../10-Observability-Foundations/)** - Monitor your cluster health.

---
*Orchestrate with confidence. Scale without limits.*