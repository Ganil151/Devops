# ⚠️ Legacy Supplemental: Kubernetes Fundamentals

> [!IMPORTANT]
> This section contains the original introductory notes for Kubernetes. While still accurate, the primary learning path has been updated to the **Part-based Master Class** structure found in the root directory.

Welcome to the supplemental beginner level. This section focuses on understanding the core components of a Kubernetes cluster, how to interact with it, and deploying your first applications.

---

## 🎯 Learning Objectives
- Understand the architecture of a Kubernetes cluster.
- Learn to use `kubectl`, the command-line tool.
- Deploy and manage your first **Pods**.
- Expose applications using **Services**.
- Understand how **Nodes** function.

---

## 📂 Directory Structure

### 1. [Cluster Architecture](README.md)
Start here! Learn about the high-level design of Kubernetes.
- **Control Plane**: The brain of the cluster (API Server, Scheduler, etc.).
- **Worker Nodes**: Where your applications actually run.

### 2. [Kubectl](README.md)
The essential tool for every Kubernetes engineer.
- Learn how to install and configure context.
- Basic commands: `get`, `describe`, `logs`, `exec`.

### 3. [Nodes](README.md)
Deep dive into the worker machines.
- **Kubelet**: The primary node agent.
- **Kube-proxy**: Network proxy on each node.
- **Container Runtime**: Software that runs containers (e.g., Docker, containerd).

### 4. [Pods](README.md)
The smallest deployable unit in Kubernetes.
- A Pod represents a single instance of a running process.
- Can contain one or more containers.
- Shared storage and network.

### 5. [Services](README.md)
How to talk to your Pods.
- **ClusterIP**: Internal only (default).
- **NodePort**: Expose on a static port on each Node.
- **LoadBalancer**: Expose externally using a cloud provider's load balancer.

---

## 🚀 Getting Started
1. **Explore the Cluster**: Go to [Cluster-Architecture](README.md) to visualize how pieces fit together.
2. **Setup CLI**: Check [Kubectl](README.md) to get your environment ready.
3. **Launch a Pod**: Follow the examples in [Pods](README.md) to run a simple Nginx container.

---

## 📚 Essential Commands
```bash
# Check cluster status
kubectl cluster-info

# list nodes
kubectl get nodes

# run a pod
kubectl run nginx --image=nginx

# list pods
kubectl get pods
```

---

## 🔗 Internal Navigation
- [Back to Part 6 Overview](../README.md)
- [Proceed to Deep Dives](../Deep-Dives/README.md)


---
## 🧭 Additional Modules
- [Diagrams](Diagrams/README.md)
