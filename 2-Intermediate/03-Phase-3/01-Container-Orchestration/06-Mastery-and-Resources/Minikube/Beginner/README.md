# Beginner Level: Getting Started with Minikube

Minikube is a tool that makes it easy to run Kubernetes locally. Minikube runs a single-node Kubernetes cluster inside a Virtual Machine (VM) or Container on your laptop for users looking to try out Kubernetes or develop with it day-to-day.

## 🎯 Learning Objectives
- Install Minikube and prerequisites.
- Start your first local cluster.
- Interact with the cluster using `kubectl`.
- Access the Kubernetes Dashboard.

## 1. Installation

### Pre-requisites
You need a container or virtual machine manager, such as:
- **Docker** (Recommended)
- QEMU
- KVM
- Podman
- VirtualBox

### Linux Installation
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

## 2. Basic Commands

### Start the Cluster
```bash
minikube start --driver=docker
```
This downloads a Kubernetes image and spins up a container that acts as your cluster node.

### Check Status
```bash
minikube status
```

### Accessing the Cluster
Minikube automatically configures `kubectl` to talk to it.
```bash
kubectl get nodes
```

### Stop and Delete
```bash
# Pause the cluster (saves resources)
minikube pause

# Stop the cluster
minikube stop

# Delete the cluster (wipes data)
minikube delete
```

## 3. The Dashboard
Minikube comes with the official UI dashboard enabled but not accessible by default.
```bash
minikube dashboard
```
This command will open a web browser pointing to your cluster's dashboard.

## 4. Deploying Your First App
```bash
# Create a deployment
kubectl create deployment hello-minikube --image=k8s.gcr.io/echoserver:1.4

# Expose it as a Service
kubectl expose deployment hello-minikube --type=NodePort --port=8080

# Get the URL to access it
minikube service hello-minikube
```

[Next: Intermediate Level](../Intermediate/README.md)
