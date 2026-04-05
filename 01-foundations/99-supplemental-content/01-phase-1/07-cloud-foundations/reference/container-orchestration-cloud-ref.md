# 📦 Container Orchestration in the Cloud
*Version 1.0 | Deploying Kubernetes at Scale*

---

## 📖 Overview
While Docker runs containers, **Orchestration** manages their lifecycle across a cluster of servers. Cloud providers offer "Managed Kubernetes" to remove the pain of managing the Control Plane.

---

## 🏗️ Managed Cloud Offerings

### 1. AWS EKS (Elastic Kubernetes Service)
**Design**: Highly robust, integrates deeply with IAM and VPC.
**Ops**: Requires the `aws-auth` ConfigMap for identity management.

### 2. Azure AKS (Azure Kubernetes Service)
**Design**: Free control plane (pay for nodes only). Native integration with Entra ID.
**Ops**: Excellent web-portal UI for inspecting pods and logs.

### 3. GCP GKE (Google Kubernetes Engine)
**Design**: The industry standard. Features "Autopilot" mode which handles node provisioning entirely.
**Ops**: Best integration with Stackdriver (Cloud Logging/Monitoring).

---

## ⚙️ Core Components

- **Control Plane**: The "Brain" (API Server, Scheduler). Managed by the provider.
- **Worker Nodes**: The servers that run your containers. You choose the VM type.
- **Ingress Controller**: The Load Balancer that routes traffic into the cluster.

---

## 🚀 Advanced Operational Patterns

- **HPA (Horizontal Pod Autoscaler)**: Scaled containers based on CPU.
- **CA (Cluster Autoscaler)**: Adds more VM nodes when there isn't enough space for new Pods.
- **Service Mesh (Istio/Linkerd)**: Manages mutual TLS and reliable communication between microservices.

---

## 💡 SRE Pro-Tips
- **Namespace Isolation**: Use namespaces to separate Dev/Stage/Prod environments within a single cluster.
- **Resource Limits**: Always set `cpu` and `memory` limits in your manifests to prevent a "Runaway Pod" from crashing a node.
- **Spot Instances**: Use Spot instances for low-priority worker nodes to save 70%+ costs.

---
**Next Step**: [FinOps & Cloud Economics →](./finops-cloud-economics-ref.md)
