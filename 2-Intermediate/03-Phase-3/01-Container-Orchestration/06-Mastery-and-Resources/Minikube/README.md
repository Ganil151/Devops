# 🏗️ Minikube: Your Local Kubernetes Lab

Minikube is an essential tool for local development, allowing you to run a single-node (or multi-node) Kubernetes cluster inside a virtual machine or container on your laptop.

---

## 🎓 Learning Path

### 🟢 [1. Beginner](./Beginner/README.md)
**Getting Started**
- Installation guides for Windows, macOS, and Linux.
- Basic commands: `minikube start`, `stop`, `delete`.
- Visualizing your cluster with the **Minikube Dashboard**.
- Deploying your first "Hello World" application.

### 🟡 [2. Intermediate](./Intermediate/README.md)
**Configuration & Development**
- **Drivers**: Choosing between Docker, Hyper-V, or VirtualBox.
- **Resource Tuning**: Allocating specific CPU and RAM to your lab.
- **Addons**: Enabling Ingress, Metrics-Server, and Registry.
- **Image Sideloading**: Using local Docker images without a registry.

### 🔴 [3. Advanced](./Advanced/README.md)
**Power User Features**
- **Multi-node Simulation**: Running 3+ nodes on a single laptop.
- **Profiles**: Managing multiple independent clusters (e.g., `dev` vs `test`).
- **Networking**: Master `minikube tunnel` for LoadBalancer access.
- **Persistence**: Testing local storage providers.

---

## 🚀 Quick Start
```bash
# Start the cluster
minikube start

# Verify the nodes
kubectl get nodes
```

---

## 🔗 Internal Navigation
- [Back to Part 6 Overview](../README.md)
