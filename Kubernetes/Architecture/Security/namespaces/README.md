# Kubernetes Namespaces

## Overview

**Kubernetes Namespaces** provide a mechanism for isolating groups of resources within a single cluster. Namespaces are intended for use in environments with many users spread across multiple teams or projects.

## Basic Namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: production
    team: backend
```

## Default Namespaces

- **default**: Default namespace for objects with no other namespace
- **kube-system**: Namespace for objects created by Kubernetes system
- **kube-public**: Readable by all users (including unauthenticated)
- **kube-node-lease**: Namespace for node lease objects

## Resource Quotas

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: production
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    pods: "10"
```

## Limit Ranges

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: limit-range
  namespace: production
spec:
  limits:
  - default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    type: Container
```

## Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

## Namespace Management

```bash
# Create namespace
kubectl create namespace production

# List namespaces
kubectl get namespaces

# Set default namespace
kubectl config set-context --current --namespace=production

# Delete namespace
kubectl delete namespace production
```

## Best Practices

- Use namespaces for environment separation
- Implement resource quotas
- Configure network policies
- Use meaningful naming conventions
- Monitor namespace resource usage

## Conclusion

Namespaces provide essential resource isolation and organization capabilities in Kubernetes clusters, enabling multi-tenancy and environment separation.