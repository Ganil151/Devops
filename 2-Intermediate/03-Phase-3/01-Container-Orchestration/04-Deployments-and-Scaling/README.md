# Kubernetes Deployments

## Overview

**Kubernetes Deployments** provide declarative updates for pods and ReplicaSets. Deployments manage the desired state of applications, handle rolling updates, and provide rollback capabilities.

## Basic Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
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
        image: nginx:1.20
        ports:
        - containerPort: 80
```

## Rolling Updates

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
```

## Update Strategies

### Rolling Update (Default)
- Gradually replaces old pods with new ones
- Zero-downtime deployments
- Configurable surge and unavailable settings

### Recreate
- Terminates all existing pods before creating new ones
- Causes downtime but ensures clean state

## Deployment Management

```bash
# Create deployment
kubectl create deployment nginx --image=nginx:1.20

# Update image
kubectl set image deployment/nginx nginx=nginx:1.21

# Scale deployment
kubectl scale deployment nginx --replicas=5

# Check rollout status
kubectl rollout status deployment/nginx

# Rollback deployment
kubectl rollout undo deployment/nginx
```

## Best Practices

- Set resource requests and limits
- Configure health checks
- Use appropriate update strategies
- Implement proper labeling
- Monitor deployment metrics

## Conclusion

Deployments are essential for managing stateless applications in Kubernetes, providing automated rollouts, scaling, and rollback capabilities.