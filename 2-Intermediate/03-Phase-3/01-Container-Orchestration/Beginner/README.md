# Beginner Level: Kubernetes Fundamentals

Welcome to the Beginner level of the Kubernetes (K8s) guide. This section focuses on understanding the core components of a Kubernetes cluster, how to interact with it, and deploying your first applications.

## 🎯 Learning Objectives
- Understand the architecture of a Kubernetes cluster.
- Learn to use `kubectl`, the command-line tool.
- Deploy and manage your first **Pods**.
- Expose applications using **Services**.
- Understand how **Nodes** function.

## 📂 Directory Structure

### 1. [Cluster Architecture](Cluster-Architecture/)
Start here! Learn about the high-level design of Kubernetes.
- **Control Plane**: The brain of the cluster (API Server, Scheduler, etc.).
- **Worker Nodes**: Where your applications actually run.

### 2. [Kubectl](Kubectl/)
The essential tool for every Kubernetes engineer.
- Learn how to install and configure context.
- Basic commands: `get`, `describe`, `logs`, `exec`.

### 3. [Nodes](Nodes/)
Deep dive into the worker machines.
- **Kubelet**: The primary node agent.
- **Kube-proxy**: Network proxy on each node.
- **Container Runtime**: Software that runs containers (e.g., Docker, containerd).

### 4. [Pods](Pods/)
The smallest deployable unit in Kubernetes.
- A Pod represents a single instance of a running process.
- Can contain one or more containers.
- Shared storage and network.

### 5. [Services](Services/)
How to talk to your Pods.
- **ClusterIP**: Internal only (default).
- **NodePort**: Expose on a static port on each Node.
- **LoadBalancer**: Expose externally using a cloud provider's load balancer.

## 🚀 Getting Started
1. **Explore the Cluster**: Go to [Cluster-Architecture](Cluster-Architecture/) to visualize how pieces fit together.
2. **Setup CLI**: Check [Kubectl](Kubectl/) to get your environment ready.
3. **Launch a Pod**: Follow the examples in [Pods](Pods/) to run a simple Nginx container.

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

[Proceed to Intermediate Level](../Intermediate/README.md)
