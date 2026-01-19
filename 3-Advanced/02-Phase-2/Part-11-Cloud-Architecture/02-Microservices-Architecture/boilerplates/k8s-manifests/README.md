# Kubernetes Manifests for Microservices

Production-ready Kubernetes configurations for microservices architecture.

## Contents

1. **Envoy Sidecar Proxy** - Service mesh sidecar configuration
2. **Dapr Configuration** - Distributed Application Runtime setup
3. **Istio VirtualService** - Traffic management with Istio

---

## 1. Envoy Sidecar Proxy

Envoy is a high-performance proxy for service mesh architectures.

### Features:
- **Traffic Management**: Load balancing, circuit breaking, retries
- **Security**: TLS termination, authentication
- **Observability**: Metrics, logging, tracing

### Files:
- [`envoy-sidecar.yaml`](./envoy-sidecar.yaml) - Deployment with Envoy sidecar
- [`envoy-config.yaml`](./envoy-config.yaml) - Envoy configuration

### Usage:
```bash
kubectl apply -f envoy-sidecar.yaml
kubectl apply -f envoy-config.yaml
```

---

## 2. Dapr Configuration

Dapr (Distributed Application Runtime) provides building blocks for microservices.

### Features:
- **Service Invocation**: Service-to-service calls with mTLS
- **State Management**: Key-value store abstraction
- **Pub/Sub**: Message broker abstraction
- **Observability**: Automatic tracing and metrics

### Files:
- [`dapr-configuration.yaml`](./dapr-configuration.yaml) - Dapr configuration
- [`dapr-deployment.yaml`](./dapr-deployment.yaml) - Deployment with Dapr sidecar

### Usage:
```bash
# Install Dapr on Kubernetes
dapr init -k

# Apply configuration
kubectl apply -f dapr-configuration.yaml
kubectl apply -f dapr-deployment.yaml
```

---

## 3. Istio VirtualService

Istio VirtualService defines routing rules for traffic management.

### Features:
- **Canary Deployments**: Gradual rollout
- **A/B Testing**: Route based on headers
- **Traffic Splitting**: Percentage-based routing
- **Fault Injection**: Test resilience

### Files:
- [`istio-virtualservice.yaml`](./istio-virtualservice.yaml) - VirtualService definition
- [`istio-destinationrule.yaml`](./istio-destinationrule.yaml) - Service subsets

### Usage:
```bash
# Install Istio
istioctl install --set profile=demo

# Label namespace for sidecar injection
kubectl label namespace default istio-injection=enabled

# Apply manifests
kubectl apply -f istio-virtualservice.yaml
kubectl apply -f istio-destinationrule.yaml
```

---

## Comparison

| Feature | Envoy (Standalone) | Dapr | Istio |
|---------|-------------------|------|-------|
| **Complexity** | Medium | Low | High |
| **Language Support** | Any | SDKs for many | Any |
| **Service Mesh** | Requires control plane | Optional | Built-in |
| **Learning Curve** | Steep | Gentle | Steep |
| **Use Case** | Custom proxy | App-level patterns | Full service mesh |

---

## Quick Start: Deploy Sample App

### 1. Deploy with Envoy Sidecar

```bash
kubectl apply -f envoy-sidecar.yaml

# Test
kubectl port-forward service/order-service 8080:80
curl http://localhost:8080/health
```

### 2. Deploy with Dapr

```bash
# Ensure Dapr is installed
dapr status -k

# Deploy
kubectl apply -f dapr-deployment.yaml

# Invoke service via Dapr
dapr invoke --app-id order-service --method health --verb GET
```

### 3. Deploy with Istio

```bash
# Deploy application
kubectl apply -f <(istioctl kube-inject -f deployment.yaml)

# Apply traffic rules
kubectl apply -f istio-virtualservice.yaml
kubectl apply -f istio-destinationrule.yaml

# Test canary deployment
curl -H "canary: true" http://order-service/api/orders
```

---

## Monitoring

### Envoy Metrics
```bash
kubectl port-forward <pod-name> 15000:15000
curl http://localhost:15000/stats/prometheus
```

### Dapr Dashboard
```bash
dapr dashboard -k
# Opens dashboard at http://localhost:8080
```

### Istio Observability
```bash
# Kiali (Service Mesh Dashboard)
istioctl dashboard kiali

# Jaeger (Distributed Tracing)
istioctl dashboard jaeger

# Grafana (Metrics)
istioctl dashboard grafana
```

---

## Best Practices

1. **Resource Limits**: Always set CPU/memory limits for sidecars
   ```yaml
   resources:
     requests:
       cpu: 100m
       memory: 128Mi
     limits:
       cpu: 500m
       memory: 512Mi
   ```

2. **Health Checks**: Configure liveness and readiness probes
   ```yaml
   livenessProbe:
     httpGet:
       path: /health
       port: 8080
     initialDelaySeconds: 30
     periodSeconds: 10
   ```

3. **Security**: Enable mTLS for service-to-service communication
   ```yaml
   # Istio
   apiVersion: security.istio.io/v1beta1
   kind: PeerAuthentication
   metadata:
     name: default
   spec:
     mtls:
       mode: STRICT
   ```

4. **Observability**: Configure distributed tracing
   ```yaml
   # Dapr tracing
   apiVersion: dapr.io/v1alpha1
   kind: Configuration
   metadata:
     name: tracing
   spec:
     tracing:
       samplingRate: "1"
       zipkin:
         endpointAddress: "http://zipkin:9411/api/v2/spans"
   ```

---

## Troubleshooting

### Debug Envoy Sidecar
```bash
# Check Envoy logs
kubectl logs <pod-name> -c envoy

# Inspect Envoy config
kubectl exec <pod-name> -c envoy -- curl -s localhost:15000/config_dump
```

### Debug Dapr
```bash
# Check Dapr sidecar logs
kubectl logs <pod-name> -c daprd

# List Dapr components
dapr components -k
```

### Debug Istio
```bash
# Check sidecar injection
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[*].name}'
# Should show: app, istio-proxy

# Analyze configuration
istioctl analyze

# Check proxy sync status
istioctl proxy-status
```

---

## Related Resources

- [Envoy Documentation](https://www.envoyproxy.io/docs)
- [Dapr Documentation](https://docs.dapr.io)
- [Istio Documentation](https://istio.io/latest/docs)

---

**Last Updated:** 2026-01-19  
**Maintainer:** DevOps Advanced Curriculum
