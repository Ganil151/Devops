# Kubernetes Services

## Overview

**Kubernetes Services** provide stable network endpoints for accessing pods. Services abstract away the complexity of pod networking and provide load balancing, service discovery, and external access to applications running in the cluster.

## Service Types

### ClusterIP (Default)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: ClusterIP
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
```

### NodePort
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nodeport-service
spec:
  type: NodePort
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080
```

### LoadBalancer
```yaml
apiVersion: v1
kind: Service
metadata:
  name: loadbalancer-service
spec:
  type: LoadBalancer
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
```

### ExternalName
```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-service
spec:
  type: ExternalName
  externalName: database.example.com
```

## Service Discovery

### DNS-Based Discovery
```bash
# Service FQDN format
<service-name>.<namespace>.svc.cluster.local
```

### Endpoints
```yaml
apiVersion: v1
kind: Endpoints
metadata:
  name: my-service
subsets:
- addresses:
  - ip: 10.244.1.5
  ports:
  - port: 8080
```

## Best Practices

- Use meaningful service names
- Implement proper health checks
- Configure appropriate session affinity
- Monitor service endpoint health

## Troubleshooting

```bash
# Check service endpoints
kubectl get endpoints my-service

# Test service connectivity
kubectl run test-pod --image=busybox -it --rm -- wget -qO- my-service
```