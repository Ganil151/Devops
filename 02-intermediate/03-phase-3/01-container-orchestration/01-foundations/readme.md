# 🏗️ Part 1: Foundations & Architecture

Welcome to the foundational stage of Kubernetes. Here, we move beyond "running containers" to understanding the distributed system that manages them. You will learn about the control plane's orchestration logic and how to effectively communicate with it.

---

## 📂 Modules in this Part

### 1. [01-Cluster-Architecture](./01-cluster-architecture/readme.md)
Deep dive into the brains of Kubernetes.
- **Control Plane internals**: How the **API Server** uses optimistic concurrency control.
- **Data Plane logic**: The **Kubelet's** role in the reconciliation loop.
- **Storage Strategy**: Why **etcd** requires an odd number of nodes (Quorum).
- **The Request Lifecycle**: Trace a request from `kubectl` to a running container.
- **Topologies**: Distinguishing between Stacked and External etcd HA patterns.

### 2. [02-Kubectl-Basics](./02-kubectl-basics/readme.md)
Master the essential tool for cluster interaction.
- **productivity**: Aliases and auto-completion.
- **Output Control**: JSONPath, Custom Columns, and Go-templates.
- **Diagnostics**: `describe`, `logs`, and `exec`.

---

## 🚀 Learning Path
1. Start with **Cluster Architecture** to understand *what* you are managing.
2. Follow up with **Kubectl Basics** to learn *how* to manage it.

---
[Back to Main Curriculum](../readme.md)
