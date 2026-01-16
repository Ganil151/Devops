# Intermediate Level: Managing Workloads & Configuration

Congratulations on mastering the basics! The Intermediate level focuses on how to manage applications at scale, handle configuration, and deal with persistent data. This is where you move from running "a pod" to running production-ready "applications".

## 🎯 Learning Objectives
- Manage application lifecycle with **Deployments**.
- Handle configuration with **ConfigMaps** and **Secrets**.
- Organize resources using **Namespaces**.
- Manage storage with **PersistentVolumes** and **StorageClasses**.
- Expose HTTP/S services using **Ingress**.

## 📂 Directory Structure

### 1. [Deployments](Deployments/)
Declarative updates for Pods.
- **ReplicaSets**: Ensure desired number of pods.
- **Rolling Updates**: Zero-downtime deployments.
- **Rollbacks**: Revert to previous versions.

### 2. [Configuration](ConfigMaps/) & [Secrets](Secrets/)
Decouple configuration from container images.
- **ConfigMaps**: Store non-confidential data (env vars, config files).
- **Secrets**: Store sensitive data (passwords, tokens, keys).

### 3. [Namespaces](Namespaces/)
Virtual clusters within a physical cluster.
- Resource isolation.
- Access control scopes.

...

### 4. [Storage](PersistentVolumes/)
Managing state in a stateless world.
- **PersistentVolumes (PV)**: Cluster storage resources.
- **PersistentVolumeClaims (PVC)**: Request for storage.
- **StorageClass**: Dynamic provisioning of storage.

### 5. [Ingress](Ingress/)
Managing external access.
- HTTP/HTTPS routing.
- Path-based and Host-based routing.

### 6. [StatefulSets](../../../../3-Advanced/01-Phase-1/04-Container-Orchestration/Advanced-K8s/StatefulSets)
Managing stateful applications that require stable identities and persistent storage.
- **Stable Pod Identities**: Predictable pod names and DNS.
- **Persistent Storage**: Dedicated PVCs for each pod.
- **Ordered Deployment**: Sequential pod creation and scaling.
- **Use Cases**: Databases, message queues, distributed systems.

### 7. [Jobs](Jobs/) & [CronJobs](CronJobs/)
- **Jobs**: Run to completion tasks.
- **CronJobs**: Scheduled tasks (like crontab).

### 8. [Helm](Helm/)
- Package manager for Kubernetes.
- Installing charts and managing releases.

### 9. [Observability](Observability/)
- **Logging**: Accessing logs, EFK stack.
- **Monitoring**: Prometheus, Grafana, Metrics Server.

## 🔨 Key Concepts
- **Labels & Selectors**: How Kubernetes resources find each other.
- **Replicas**: Scaling your application horizontally.
- **Volume Mounting**: Attaching storage to containers.

## 📚 Essential Commands
```bash
# Create a deployment
kubectl create deployment web --image=nginx --replicas=3

# Scale a deployment
kubectl scale deployment web --replicas=5

# Watch a rolling update
kubectl rollout status deployment/web

# Get resources in a namespace
kubectl get pods -n my-namespace
```

[Back to Beginner](../Beginner/README.md) | [Proceed to Advanced Level](../../../../README.md)
