# Kubernetes (K8s) Orchestration Guide

Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications. It has become the "OS of the Data Center."

---

## 1. Why Orchestration?

While Docker handles the lifecycle of a single container, Kubernetes handles the lifecycle of **clusters** of containers. It ensures:
- **Self-healing**: Restarts containers that fail, replaces and reschedules containers when nodes die.
- **Bin Packing**: Automatically places containers based on their resource requirements.
- **Service Discovery**: Exposes containers using their own DNS name or IP address.
- **Automated Rollouts/Rollbacks**: Seamlessly move to new versions of your app.

---

## 2. Cluster Architecture

A Kubernetes cluster consists of two types of resources:
1.  **Control Plane**: The "Brain" of the cluster. It makes global decisions about the cluster (e.g., scheduling).
    - `kube-apiserver`: The front-end for the control plane.
    - `etcd`: Consistent and highly-available key-value store for cluster data.
    - `kube-scheduler`: Watches for new pods and assigns them to nodes.
    - `kube-controller-manager`: Runs controller processes (Node, Job, Endpoint controllers).

2.  **Nodes (Worker Data Plane)**: The machines where your applications run.
    - `kubelet`: An agent that runs on each node and ensures containers are running in a pod.
    - `kube-proxy`: Maintains network rules on nodes.
    - `Container Runtime`: Software that runs containers (e.g., Docker, containerd).

---

## 3. Learning Path Overview

### 🟢 [Beginner Level](./Beginner/README.md)
**Focus**: Understanding the basics and the "Object Model".
- **Pods**: The smallest deployable unit in K8s.
- **Nodes**: Physical or virtual machines in the cluster.
- **Services**: Stable networking for your pods.

### 🟡 [Intermediate Level](./Intermediate/README.md)
**Focus**: Managing state and scale.
- **Deployments**: Declarative updates for Pods and ReplicaSets.
- **ConfigMaps & Secrets**: Externalizing configuration and sensitive data.
- **Ingress**: Managing external access to services (HTTP/HTTPS).

### 🔴 [Advanced Level](./Advanced/README.md)
**Focus**: Production operations and specialized workloads.
- **StatefulSets**: Managing stateful applications (Databases).
- **CRDs & Operators**: Extending the Kubernetes API.
- **EKS**: Running K8s on AWS at scale.

---

## 4. Best Practices
- **Namespace Isolation**: Use Namespaces to logically separate environments (Dev, Staging, Prod).
- **Resource Quotas**: Prevent one team from "taking over" the whole cluster.
- **GitOps**: Always manage your cluster state using Git (e.g., [ArgoCD](../ArgoCD/README.md)).
- **Monitoring**: Implement cluster-wide observability using the [Kube-Prometheus-Stack](../../3-Advanced/02-Observability/01-Kube-Prometheus-Stack/README.md).

---
**Deep Dive**: Learn about the [Kubernetes Control Plane](./Advanced/README.md#2-control-plane-deep-dive) for architectural excellence.