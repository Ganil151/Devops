# Kubernetes Vertical Pod Autoscaler (VPA)

## Overview

**Kubernetes Vertical Pod Autoscaler (VPA)** automatically adjusts CPU and memory requests for containers in pods. VPA helps optimize resource allocation and can work in recommendation, update, or off modes.

## Basic VPA

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: webapp-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  updatePolicy:
    updateMode: "Auto"
```

## VPA Update Modes

### Auto Mode
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: auto-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  updatePolicy:
    updateMode: "Auto"  # Automatically update resource requests
```

### Recreation Mode
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: recreate-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  updatePolicy:
    updateMode: "Recreate"  # Recreate pods with new requests
```

### Initial Mode
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: initial-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  updatePolicy:
    updateMode: "Initial"  # Set requests only for new pods
```

### Off Mode
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: off-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  updatePolicy:
    updateMode: "Off"  # Only provide recommendations
```

## Resource Policy

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: policy-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: webapp
      maxAllowed:
        cpu: 2
        memory: 4Gi
      minAllowed:
        cpu: 100m
        memory: 128Mi
      controlledResources: ["cpu", "memory"]
      controlledValues: RequestsAndLimits
    - containerName: sidecar
      mode: "Off"  # Don't autoscale this container
```

## Complete VPA Example

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: comprehensive-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  updatePolicy:
    updateMode: "Auto"
    minReplicas: 2  # Minimum replicas during updates
  resourcePolicy:
    containerPolicies:
    - containerName: webapp
      maxAllowed:
        cpu: "4"
        memory: "8Gi"
      minAllowed:
        cpu: "100m"
        memory: "128Mi"
      controlledResources: ["cpu", "memory"]
      controlledValues: RequestsAndLimits
```

## VPA Installation

```yaml
# VPA Components
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vpa-recommender
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vpa-recommender
  template:
    spec:
      containers:
      - name: recommender
        image: k8s.gcr.io/autoscaling/vpa-recommender:0.13.0
        command:
        - ./recommender
        - --v=4
        - --stderrthreshold=info
        - --pod-recommendation-min-cpu-millicores=25
        - --pod-recommendation-min-memory-mb=250
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vpa-updater
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vpa-updater
  template:
    spec:
      containers:
      - name: updater
        image: k8s.gcr.io/autoscaling/vpa-updater:0.13.0
        command:
        - ./updater
        - --v=4
        - --stderrthreshold=info
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vpa-admission-controller
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vpa-admission-controller
  template:
    spec:
      containers:
      - name: admission-controller
        image: k8s.gcr.io/autoscaling/vpa-admission-controller:0.13.0
        command:
        - ./admission-controller
        - --v=4
        - --stderrthreshold=info
        - --client-ca-file=/etc/certs/ca.crt
        - --tls-cert-file=/etc/certs/tls.crt
        - --tls-private-key-file=/etc/certs/tls.key
```

## VPA Management

```bash
# Create VPA
kubectl apply -f vpa.yaml

# Get VPAs
kubectl get vpa

# Describe VPA
kubectl describe vpa webapp-vpa

# Get VPA recommendations
kubectl get vpa webapp-vpa -o jsonpath='{.status.recommendation}'

# Delete VPA
kubectl delete vpa webapp-vpa
```

## VPA Status and Recommendations

```bash
# Check VPA status
kubectl get vpa webapp-vpa -o yaml

# Get current recommendations
kubectl get vpa webapp-vpa -o jsonpath='{.status.recommendation.containerRecommendations[0]}'

# Get target recommendations
kubectl get vpa webapp-vpa -o jsonpath='{.status.recommendation.containerRecommendations[0].target}'

# Get lower bound recommendations
kubectl get vpa webapp-vpa -o jsonpath='{.status.recommendation.containerRecommendations[0].lowerBound}'

# Get upper bound recommendations
kubectl get vpa webapp-vpa -o jsonpath='{.status.recommendation.containerRecommendations[0].upperBound}'
```

## VPA with StatefulSet

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: database-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: StatefulSet
    name: postgres
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: postgres
      maxAllowed:
        cpu: "8"
        memory: "16Gi"
      minAllowed:
        cpu: "500m"
        memory: "1Gi"
      controlledResources: ["memory"]  # Only scale memory for database
```

## VPA Best Practices

### 1. Resource Boundaries
- Set appropriate min/max limits
- Consider application requirements
- Monitor resource usage patterns
- Test scaling behavior

### 2. Update Strategy
- Use "Off" mode for initial assessment
- Start with "Initial" mode for new deployments
- Use "Auto" mode for stable applications
- Consider "Recreate" for stateful applications

### 3. Container Policies
- Configure per-container policies
- Exclude sidecar containers if needed
- Set controlled resources appropriately
- Monitor recommendation accuracy

## VPA and HPA Compatibility

VPA and HPA should not target the same metrics:

```yaml
# VPA for CPU/Memory
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: webapp-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  resourcePolicy:
    containerPolicies:
    - containerName: webapp
      controlledResources: ["memory"]  # Only memory
---
# HPA for custom metrics
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: webapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  metrics:
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "100"
```

## Monitoring VPA

```bash
# Check VPA components
kubectl get pods -n kube-system | grep vpa

# Check VPA logs
kubectl logs -n kube-system deployment/vpa-recommender
kubectl logs -n kube-system deployment/vpa-updater
kubectl logs -n kube-system deployment/vpa-admission-controller

# Monitor resource changes
kubectl get pods -l app=webapp -o jsonpath='{.items[*].spec.containers[*].resources}'
```

## Troubleshooting

### Common Issues

#### 1. VPA Not Providing Recommendations
```bash
# Check VPA status
kubectl describe vpa webapp-vpa

# Check metrics server
kubectl top pods

# Check VPA components
kubectl get pods -n kube-system | grep vpa

# Check target deployment
kubectl get deployment webapp
```

#### 2. Pods Not Being Updated
```bash
# Check update mode
kubectl get vpa webapp-vpa -o jsonpath='{.spec.updatePolicy.updateMode}'

# Check admission controller
kubectl logs -n kube-system deployment/vpa-admission-controller

# Check pod events
kubectl describe pod webapp-xxx
```

#### 3. Resource Recommendations Too High/Low
```bash
# Check resource policy
kubectl get vpa webapp-vpa -o jsonpath='{.spec.resourcePolicy}'

# Check historical usage
kubectl top pods --containers

# Adjust min/max limits
kubectl patch vpa webapp-vpa -p '{"spec":{"resourcePolicy":{"containerPolicies":[{"containerName":"webapp","maxAllowed":{"memory":"2Gi"}}]}}}'
```

## VPA Metrics

VPA provides several recommendation types:
- **Target**: Recommended resource requests
- **Lower Bound**: Minimum recommended resources
- **Upper Bound**: Maximum recommended resources
- **Uncapped Target**: Recommendation without policy limits

## Conclusion

VPA provides essential vertical scaling capabilities for Kubernetes applications, optimizing resource allocation and improving cluster efficiency through intelligent resource request adjustments.