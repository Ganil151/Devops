# 🛡️ Part 5: Cloud Ops & Administration

Transition from "managing applications" to "managing platforms." This part focuses on running Kubernetes in production environments and enforcing corporate security standards.

---

## 📂 Modules in this Part

### 1. [10-Managed-Kubernetes-EKS](./10-managed-kubernetes-eks/readme.md)
Production-grade Kubernetes on AWS.
- **Shared Responsibility**: Understanding the **Control Plane as a Service** model.
- **Amazon EKS internals**: IAM OIDC providers, IRSA (IAM Roles for Service Accounts), and AWS Load Balancer Controller.
- **Node Management**: Comparing **Fargate** (Serverless) vs. **Managed Node Groups** vs. **Self-Managed Nodes**.

### 2. [11-Cluster-Administration](./11-cluster-administration/readme.md)
Securing and Governing the platform.
- **Identity (RBAC)**: Implementing **Least Privilege** with ClusterRoles, ServiceAccounts, and Groups.
- **Resource Governance**: Enforcing **Resource Quotas**, **LimitRanges**, and isolation via **Namespaces**.
- **Security Posture**: Introduction to **Admission Controllers** (OPA/Gatekeeper) and **Network Security** hardening.

---

## 🚀 Learning Path
1. Explore **Managed Kubernetes** to understand how cloud providers simplify operations.
2. Master **Cluster Administration** to secure and govern your enterprise platform.

---
[Back to Main Curriculum](../readme.md)
