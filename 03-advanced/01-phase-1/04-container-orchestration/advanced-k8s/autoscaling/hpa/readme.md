# Kubernetes Horizontal Pod Autoscaler (HPA)

## Overview

**Kubernetes Horizontal Pod Autoscaler (HPA)** automatically scales the number of pods in a deployment, replica set, or stateful set based on observed CPU utilization, memory usage, or custom metrics.

## Basic HPA

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: webapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## CPU and Memory Metrics

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: cpu-memory-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 1
  maxReplicas: 15
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

## Custom Metrics HPA

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: custom-metrics-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "100"
  - type: Object
    object:
      metric:
        name: queue_length
      describedObject:
        apiVersion: v1
        kind: Service
        name: message-queue
      target:
        type: Value
        value: "50"
```

## External Metrics HPA

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: external-metrics-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: worker
  minReplicas: 1
  maxReplicas: 50
  metrics:
  - type: External
    external:
      metric:
        name: sqs_queue_length
        selector:
          matchLabels:
            queue: "work-queue"
      target:
        type: AverageValue
        averageValue: "10"
```

## Behavior Configuration

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: behavior-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  minReplicas: 2
  maxReplicas: 100
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 4
        periodSeconds: 15
      selectPolicy: Max
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
      - type: Pods
        value: 2
        periodSeconds: 60
      selectPolicy: Min
```

## Prerequisites

### Metrics Server
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: metrics-server
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  template:
    spec:
      containers:
      - name: metrics-server
        image: k8s.gcr.io/metrics-server/metrics-server:v0.6.1
        args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
```

### Resource Requests
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  template:
    spec:
      containers:
      - name: webapp
        image: webapp:latest
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
```

## HPA Management

```bash
# Create HPA
kubectl apply -f hpa.yaml

# Create HPA imperatively
kubectl autoscale deployment webapp --cpu-percent=70 --min=2 --max=10

# Get HPAs
kubectl get hpa

# Describe HPA
kubectl describe hpa webapp-hpa

# Check HPA status
kubectl get hpa webapp-hpa -o yaml

# Delete HPA
kubectl delete hpa webapp-hpa
```

## Monitoring HPA

```bash
# Watch HPA in real-time
kubectl get hpa -w

# Check current metrics
kubectl top pods -l app=webapp

# Check HPA events
kubectl describe hpa webapp-hpa

# Get HPA conditions
kubectl get hpa webapp-hpa -o jsonpath='{.status.conditions}'
```

## Load Testing

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: load-generator
spec:
  containers:
  - name: load-generator
    image: busybox
    command:
    - /bin/sh
    - -c
    - while true; do wget -q -O- http://webapp-service/; done
```

## Custom Metrics Setup

### Prometheus Adapter
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: adapter-config
  namespace: monitoring
data:
  config.yaml: |
    rules:
    - seriesQuery: 'http_requests_per_second{namespace!="",pod!=""}'
      resources:
        overrides:
          namespace: {resource: "namespace"}
          pod: {resource: "pod"}
      name:
        matches: "^(.*)_per_second"
        as: "${1}_rate"
      metricsQuery: 'sum(<<.Series>>{<<.LabelMatchers>>}) by (<<.GroupBy>>)'
```

## HPA Best Practices

### 1. Resource Configuration
- Always set resource requests
- Use appropriate CPU/memory targets
- Consider application startup time
- Monitor resource utilization patterns

### 2. Scaling Behavior
- Configure appropriate stabilization windows
- Set reasonable min/max replicas
- Use gradual scaling policies
- Test scaling behavior under load

### 3. Metrics Selection
- Choose relevant metrics for your application
- Combine multiple metrics when appropriate
- Use custom metrics for business logic
- Monitor metric collection reliability

## Troubleshooting

### Common Issues

#### 1. HPA Not Scaling
```bash
# Check metrics availability
kubectl top pods

# Check HPA status
kubectl describe hpa my-hpa

# Verify resource requests
kubectl describe deployment my-app

# Check metrics server
kubectl get pods -n kube-system | grep metrics-server
```

#### 2. Metrics Not Available
```bash
# Check metrics server logs
kubectl logs -n kube-system deployment/metrics-server

# Test metrics API
kubectl get --raw /apis/metrics.k8s.io/v1beta1/pods

# Check custom metrics API
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1
```

#### 3. Scaling Too Aggressive
```bash
# Check scaling events
kubectl describe hpa my-hpa

# Adjust behavior configuration
kubectl patch hpa my-hpa -p '{"spec":{"behavior":{"scaleUp":{"stabilizationWindowSeconds":300}}}}'
```

## HPA Algorithms

### CPU Utilization Calculation
```
desiredReplicas = ceil[currentReplicas * (currentMetricValue / desiredMetricValue)]
```

### Multiple Metrics
HPA calculates desired replicas for each metric and uses the highest value.

## Advanced Configurations

### Multiple HPAs
```yaml
# HPA for different time periods
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: business-hours-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  minReplicas: 5  # Higher baseline during business hours
  maxReplicas: 50
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
```

## Conclusion

HPA provides essential automatic scaling capabilities for Kubernetes applications, enabling efficient resource utilization and improved application performance under varying load conditions.