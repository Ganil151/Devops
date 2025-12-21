# Kubernetes StatefulSets: Managing Stateful Applications

## Overview

**StatefulSets** are Kubernetes workload controllers designed specifically for stateful applications that require stable network identities, persistent storage, and ordered deployment. Unlike Deployments that treat pods as interchangeable, StatefulSets maintain each pod's unique identity and state across rescheduling.

---

## Why StatefulSets?

### The Problem with Stateless Deployments

Traditional **Deployments** are perfect for stateless applications where:
- Any pod can handle any request
- Pods are completely interchangeable
- Data doesn't need to persist across restarts
- Order of deployment doesn't matter

However, many applications are **stateful** and have special requirements:
- **Databases** (PostgreSQL, MySQL, MongoDB) need persistent storage
- **Message Queues** (Kafka, RabbitMQ) require stable network identities
- **Distributed Systems** (Elasticsearch, Cassandra) need ordered deployment
- **Caching Systems** (Redis Cluster) require stable hostnames

### The StatefulSet Solution

StatefulSets provide three critical guarantees:

1. **Stable, Unique Network Identifiers**
   - Each pod gets a predictable hostname: `{statefulset-name}-{ordinal}`
   - Example: `postgres-0`, `postgres-1`, `postgres-2`
   - Hostnames persist across rescheduling and pod recreation

2. **Stable, Persistent Storage**
   - Each pod gets its own PersistentVolumeClaim (PVC)
   - PVCs are retained even when pods are deleted
   - Data survives pod restarts and rescheduling

3. **Ordered Deployment and Scaling**
   - Pods are created in order: `pod-0` → `pod-1` → `pod-2`
   - Each pod must be Running and Ready before the next is created
   - Scaling down happens in reverse order
   - Ensures initialization dependencies are respected

---

## StatefulSet vs Deployment: Decision Matrix

| Feature | Deployment | StatefulSet |
|---------|-----------|-------------|
| **Pod Identity** | Random, ephemeral names | Stable, predictable names |
| **Network Identity** | Unstable, changes on restart | Stable DNS hostname |
| **Storage** | Shared or ephemeral volumes | Dedicated PVC per pod |
| **Deployment Order** | Parallel, unordered | Sequential, ordered |
| **Scaling** | All pods created/deleted simultaneously | One pod at a time |
| **Use Cases** | Web servers, APIs, stateless apps | Databases, message queues, distributed systems |
| **Update Strategy** | Rolling update, all pods replaceable | Ordered rolling update with stable identity |

### When to Use StatefulSets

✅ **Use StatefulSets when:**
- You need persistent storage per pod
- Pods have unique identities (master/slave, leader/follower)
- Order of deployment matters
- You need stable network hostnames
- Running databases, message queues, or distributed systems

❌ **Use Deployments when:**
- Application is stateless
- Any pod can handle any request
- No persistent data storage needed
- Pods are completely interchangeable
- Running web servers, APIs, or compute workers

---

## Core Concepts

### 1. Pod Naming Convention

StatefulSets create pods with predictable, ordinal-based names:

```
{statefulset-name}-{ordinal}
```

**Example:** A StatefulSet named `web` with 3 replicas creates:
- `web-0` (created first)
- `web-1` (created second)
- `web-2` (created third)

These names are **stable** and persist across pod restarts, rescheduling, and updates.

### 2. Headless Services

StatefulSets require a **Headless Service** to provide stable DNS entries for each pod.

**What is a Headless Service?**
- A Service with `clusterIP: None`
- Instead of load balancing, it returns individual pod IPs
- Creates DNS records for each pod

**DNS Pattern:**
```
{pod-name}.{service-name}.{namespace}.svc.cluster.local
```

**Example:**
```
web-0.nginx.default.svc.cluster.local
web-1.nginx.default.svc.cluster.local
web-2.nginx.default.svc.cluster.local
```

This allows other applications to address specific pods directly.

### 3. PersistentVolumeClaim Templates

StatefulSets use **volumeClaimTemplates** to automatically create a dedicated PVC for each pod.

**PVC Naming Pattern:**
```
{volume-name}-{statefulset-name}-{ordinal}
```

**Example:** For a volume template named `data`:
- `data-web-0`
- `data-web-1`
- `data-web-2`

**Key Behaviors:**
- PVCs are created automatically when pods are created
- PVCs are **NOT** deleted when StatefulSet is deleted (by default)
- When a pod is rescheduled, it reattaches to the same PVC
- Ensures data persists across pod lifecycle events

---

## Basic StatefulSet Example

Here's a complete example deploying a simple nginx StatefulSet:

### Headless Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-headless
  labels:
    app: nginx
spec:
  # Set clusterIP to None for headless service
  clusterIP: None
  selector:
    app: nginx
  ports:
  - port: 80
    name: web
```

### StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  # Reference to the headless service
  serviceName: "nginx-headless"
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  # Volume claim template creates PVCs automatically
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: "standard"
      resources:
        requests:
          storage: 1Gi
```

### What Happens When You Deploy This?

1. **Service Created**: `nginx-headless` service is created
2. **Ordered Pod Creation**:
   - `web-0` is created and waits to be Running and Ready
   - Once `web-0` is ready, `web-1` is created
   - Once `web-1` is ready, `web-2` is created
3. **PVC Creation**: For each pod, a PVC is created:
   - `www-web-0`
   - `www-web-1`
   - `www-web-2`
4. **DNS Records**: Each pod gets a stable DNS entry:
   - `web-0.nginx-headless.default.svc.cluster.local`
   - `web-1.nginx-headless.default.svc.cluster.local`
   - `web-2.nginx-headless.default.svc.cluster.local`

---

## Scaling StatefulSets

### Scaling Up

```bash
kubectl scale statefulset web --replicas=5
```

**Behavior:**
- Pods are created one at a time in order
- `web-3` is created, waits to be Ready
- Then `web-4` is created
- New PVCs are created: `www-web-3`, `www-web-4`

### Scaling Down

```bash
kubectl scale statefulset web --replicas=2
```

**Behavior:**
- Pods are deleted in reverse order
- `web-4` is deleted first
- Then `web-3` is deleted
- **Important:** PVCs are NOT deleted (data is preserved)

### Deleting PVCs Manually

```bash
# StatefulSet deletion does not delete PVCs by default
kubectl delete statefulset web

# You must manually delete PVCs if you want to remove data
kubectl delete pvc www-web-0 www-web-1 www-web-2
```

---

## Update Strategies

StatefulSets support two update strategies:

### 1. RollingUpdate (Default)

Updates pods one at a time in reverse ordinal order.

```yaml
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 0  # Update all pods (default)
```

**Update Process:**
- Pod with highest ordinal is updated first
- Update: `web-2` → wait for Ready → `web-1` → wait for Ready → `web-0`
- Ensures only one pod is down at a time

**Canary Deployments with Partition:**

```yaml
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 2  # Only update pods with ordinal >= 2
```

- Only `web-2` will be updated
- `web-0` and `web-1` remain on old version
- Useful for testing updates on a subset of pods

### 2. OnDelete

Pods are only updated when manually deleted.

```yaml
spec:
  updateStrategy:
    type: OnDelete
```

**Update Process:**
1. Update the StatefulSet manifest
2. Manually delete pods: `kubectl delete pod web-0`
3. Replacement pod is created with new spec
4. Provides precise control over update timing

---

## Pod Management Policies

Controls how pods are created and deleted.

### OrderedReady (Default)

```yaml
spec:
  podManagementPolicy: OrderedReady
```

- Strict ordering: pods created/deleted one at a time
- Guarantees previous pod is Ready before starting next
- Best for applications with initialization dependencies

### Parallel

```yaml
spec:
  podManagementPolicy: Parallel
```

- Pods created/deleted in parallel
- No waiting for previous pods to be Ready
- Faster deployment but no ordering guarantees
- Use when pods don't have dependencies on each other

---

## Common Commands

```bash
# Create StatefulSet
kubectl apply -f statefulset.yaml

# Get StatefulSets
kubectl get statefulset
kubectl get sts  # short form

# Get pods with labels
kubectl get pods -l app=nginx -o wide

# Describe StatefulSet
kubectl describe statefulset web

# Check PVCs
kubectl get pvc -l app=nginx

# Scale StatefulSet
kubectl scale statefulset web --replicas=5

# Update image
kubectl set image statefulset/web nginx=nginx:1.22

# Delete StatefulSet (keep PVCs)
kubectl delete statefulset web --cascade=orphan

# Delete StatefulSet and pods (keep PVCs)
kubectl delete statefulset web

# Delete specific pod (will be recreated)
kubectl delete pod web-0

# Delete PVCs manually
kubectl delete pvc www-web-0 www-web-1 www-web-2
```

---

## Best Practices

### 1. Always Use Headless Services
```yaml
# Required for stable pod DNS
clusterIP: None
```

### 2. Configure Proper Storage Classes
```yaml
volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      storageClassName: "fast-ssd"  # Use appropriate storage class
      accessModes: ["ReadWriteOnce"]
```

### 3. Set Resource Limits
```yaml
resources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "1000m"
```

### 4. Use Init Containers for Setup
```yaml
initContainers:
- name: init-config
  image: busybox
  command: ['sh', '-c', 'echo "Initializing pod $(hostname)"']
```

### 5. Implement Health Checks
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 10
```

### 6. Plan for Persistent Volume Lifecycle
- PVCs are not auto-deleted to prevent data loss
- Implement backup strategies for critical data
- Document PVC cleanup procedures

### 7. Monitor Persistent Volume Usage
```bash
# Check PVC usage
kubectl get pvc
kubectl describe pvc www-web-0
```

---

## Next Steps

- **[Practical Examples](./examples/)**: Real-world StatefulSet configurations for MySQL, Redis, and Kafka
- **[Advanced StatefulSets](../../../3-Advanced/03-Advanced-K8s/StatefulSets/)**: Production patterns, backup strategies, and advanced configurations
- **[Diagrams](../../Beginner/Diagrams/statefulsets/)**: Visual representations of StatefulSet architecture

---

## Summary

StatefulSets are essential for running stateful applications in Kubernetes. They provide:
- ✅ **Stable pod identities** with predictable naming
- ✅ **Persistent storage** that survives pod restarts
- ✅ **Ordered deployment** for initialization dependencies
- ✅ **Stable network hostnames** for direct pod addressing

Use StatefulSets when your application needs persistent storage, stable network identities, or ordered deployment. For stateless applications, prefer Deployments.
