# Kubernetes Pod Disruption Budget (PDB)

## Overview

**Kubernetes Pod Disruption Budget (PDB)** limits the number of pods that can be simultaneously disrupted during voluntary disruptions like node maintenance, cluster upgrades, or application updates.

## Basic PDB

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: webapp-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: webapp
```

## PDB with Percentage

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: webapp-pdb-percent
spec:
  minAvailable: 50%
  selector:
    matchLabels:
      app: webapp
```

## PDB with Max Unavailable

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: webapp-pdb-max
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      app: webapp
```

## Database PDB

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: database-pdb
spec:
  minAvailable: 1  # Always keep at least 1 database pod
  selector:
    matchLabels:
      app: postgres
      role: primary
```

## Frontend Application PDB

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: frontend-pdb
spec:
  maxUnavailable: 25%  # Allow up to 25% of pods to be unavailable
  selector:
    matchLabels:
      app: frontend
      tier: web
```

## Microservice PDB

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: user-service-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: user-service
      version: v1
```

## PDB for StatefulSet

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: elasticsearch-pdb
spec:
  maxUnavailable: 1  # Only one Elasticsearch node can be down
  selector:
    matchLabels:
      app: elasticsearch
```

## Multiple PDBs for Different Components

```yaml
# API Server PDB
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: api-server-pdb
spec:
  minAvailable: 3
  selector:
    matchLabels:
      component: api-server
---
# Worker PDB
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: worker-pdb
spec:
  maxUnavailable: 50%
  selector:
    matchLabels:
      component: worker
---
# Cache PDB
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: cache-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      component: redis
```

## PDB Management

```bash
# Create PDB
kubectl apply -f pdb.yaml

# Get PDBs
kubectl get pdb

# Describe PDB
kubectl describe pdb webapp-pdb

# Check PDB status
kubectl get pdb webapp-pdb -o yaml

# Delete PDB
kubectl delete pdb webapp-pdb
```

## PDB Status

```bash
# Check current status
kubectl get pdb webapp-pdb -o jsonpath='{.status}'

# Check allowed disruptions
kubectl get pdb webapp-pdb -o jsonpath='{.status.disruptionsAllowed}'

# Check current healthy pods
kubectl get pdb webapp-pdb -o jsonpath='{.status.currentHealthy}'

# Check desired healthy pods
kubectl get pdb webapp-pdb -o jsonpath='{.status.desiredHealthy}'

# Check expected pods
kubectl get pdb webapp-pdb -o jsonpath='{.status.expectedPods}'
```

## Disruption Types

### Voluntary Disruptions
- Node maintenance
- Cluster upgrades
- Application updates
- Pod evictions

### Involuntary Disruptions
- Hardware failures
- Node crashes
- Network partitions
- Out of memory kills

## PDB Best Practices

### 1. Application Design
- Design for high availability
- Use multiple replicas
- Implement graceful shutdown
- Handle pod restarts gracefully

### 2. PDB Configuration
- Set appropriate min/max values
- Consider application requirements
- Test disruption scenarios
- Monitor PDB effectiveness

### 3. Deployment Strategy
- Use rolling updates
- Configure readiness probes
- Set appropriate termination grace periods
- Implement health checks

## Example with Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 5
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: webapp:latest
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: webapp-pdb
spec:
  minAvailable: 3  # Keep at least 3 out of 5 pods running
  selector:
    matchLabels:
      app: webapp
```

## Node Maintenance with PDB

```bash
# Drain node (respects PDB)
kubectl drain node-1 --ignore-daemonsets --delete-emptydir-data

# Check PDB status during drain
kubectl get pdb -w

# Force drain (ignores PDB)
kubectl drain node-1 --ignore-daemonsets --delete-emptydir-data --force
```

## Monitoring PDB

```bash
# Watch PDB status
kubectl get pdb -w

# Check pod distribution
kubectl get pods -o wide -l app=webapp

# Monitor during disruptions
kubectl get events --field-selector reason=EvictionBlocked

# Check eviction events
kubectl get events --field-selector involvedObject.kind=Pod,reason=Evicted
```

## Troubleshooting

### Common Issues

#### 1. Eviction Blocked
```bash
# Check PDB status
kubectl describe pdb webapp-pdb

# Check pod health
kubectl get pods -l app=webapp

# Check readiness probes
kubectl describe pod webapp-xxx

# Temporarily adjust PDB
kubectl patch pdb webapp-pdb -p '{"spec":{"minAvailable":1}}'
```

#### 2. PDB Not Working
```bash
# Verify selector matches pods
kubectl get pods -l app=webapp --show-labels

# Check PDB selector
kubectl get pdb webapp-pdb -o jsonpath='{.spec.selector}'

# Verify PDB is active
kubectl describe pdb webapp-pdb
```

#### 3. Stuck Deployments
```bash
# Check deployment status
kubectl rollout status deployment webapp

# Check PDB constraints
kubectl get pdb webapp-pdb -o jsonpath='{.status.disruptionsAllowed}'

# Check pod readiness
kubectl get pods -l app=webapp -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}'
```

## Advanced PDB Scenarios

### Blue-Green Deployment PDB
```yaml
# Blue environment PDB
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: webapp-blue-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: webapp
      version: blue
---
# Green environment PDB
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: webapp-green-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: webapp
      version: green
```

### Canary Deployment PDB
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: webapp-stable-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: webapp
      track: stable
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: webapp-canary-pdb
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      app: webapp
      track: canary
```

## PDB Validation

```bash
# Test PDB with pod deletion
kubectl delete pod webapp-xxx

# Simulate node drain
kubectl cordon node-1
kubectl drain node-1 --dry-run=client

# Check eviction API
kubectl get pods webapp-xxx -o yaml | grep -A 10 deletionTimestamp
```

## Conclusion

Pod Disruption Budgets provide essential availability guarantees during voluntary disruptions, ensuring applications maintain minimum service levels during maintenance operations and updates.