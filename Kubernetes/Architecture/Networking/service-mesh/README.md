# Kubernetes Service Mesh

## Overview

**Service Mesh** provides a dedicated infrastructure layer for handling service-to-service communication, offering advanced traffic management, security, and observability features for microservices.

## Service Mesh Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Service Mesh                             │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │ Control     │  │    Data     │  │   Observability │     │
│  │ Plane       │  │   Plane     │  │                 │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
│         │                 │                 │              │
│         ▼                 ▼                 ▼              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │ Config      │  │ Sidecar     │  │ Metrics         │     │
│  │ Management  │  │ Proxies     │  │ Tracing         │     │
│  │ Policy      │  │ (Envoy)     │  │ Logging         │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## Popular Service Mesh Solutions

### 1. Istio

#### Istio Installation
```bash
# Download Istio
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
export PATH=$PWD/bin:$PATH

# Install Istio
istioctl install --set values.defaultRevision=default

# Enable sidecar injection
kubectl label namespace default istio-injection=enabled
```

#### Istio Configuration
```yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: control-plane
spec:
  values:
    defaultRevision: default
  components:
    pilot:
      k8s:
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
```

#### Traffic Management
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  http:
  - match:
    - headers:
        end-user:
          exact: jason
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v1
```

### 2. Linkerd

#### Linkerd Installation
```bash
# Install Linkerd CLI
curl -sL https://run.linkerd.io/install | sh
export PATH=$PATH:$HOME/.linkerd2/bin

# Install Linkerd control plane
linkerd install | kubectl apply -f -

# Inject sidecar
kubectl get deploy -o yaml | linkerd inject - | kubectl apply -f -
```

#### Linkerd Traffic Split
```yaml
apiVersion: split.smi-spec.io/v1alpha1
kind: TrafficSplit
metadata:
  name: webapp-split
spec:
  service: webapp
  backends:
  - service: webapp-v1
    weight: 90
  - service: webapp-v2
    weight: 10
```

### 3. Consul Connect

#### Consul Connect Configuration
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: consul-config
data:
  config.json: |
    {
      "connect": {
        "enabled": true
      },
      "ports": {
        "grpc": 8502
      }
    }
```

## Service Mesh Features

### Traffic Management

#### Circuit Breaking
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews-cb
spec:
  host: reviews
  trafficPolicy:
    outlierDetection:
      consecutiveErrors: 3
      interval: 30s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
```

#### Retry Policy
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews-retry
spec:
  http:
  - route:
    - destination:
        host: reviews
    retries:
      attempts: 3
      perTryTimeout: 2s
```

#### Load Balancing
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews-lb
spec:
  host: reviews
  trafficPolicy:
    loadBalancer:
      simple: LEAST_CONN
```

### Security Features

#### mTLS Configuration
```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
```

#### Authorization Policy
```yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-read
spec:
  selector:
    matchLabels:
      app: httpbin
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/default/sa/sleep"]
    to:
    - operation:
        methods: ["GET"]
```

### Observability

#### Distributed Tracing
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: istio
  namespace: istio-system
data:
  mesh: |
    defaultConfig:
      tracing:
        sampling: 100.0
      proxyStatsMatcher:
        inclusionRegexps:
        - ".*outlier_detection.*"
        - ".*circuit_breakers.*"
```

#### Metrics Collection
```yaml
apiVersion: telemetry.istio.io/v1alpha1
kind: Telemetry
metadata:
  name: metrics
spec:
  metrics:
  - providers:
    - name: prometheus
  - overrides:
    - match:
        metric: ALL_METRICS
      tagOverrides:
        request_protocol:
          value: "http"
```

## Service Mesh Comparison

| Feature | Istio | Linkerd | Consul Connect | Cilium Service Mesh |
|---------|-------|---------|----------------|---------------------|
| **Proxy** | Envoy | Linkerd2-proxy | Envoy | Envoy |
| **mTLS** | ✅ Auto | ✅ Auto | ✅ Manual | ✅ Auto |
| **Traffic Management** | ✅ Advanced | ✅ Basic | ✅ Basic | ✅ Advanced |
| **Observability** | ✅ Full | ✅ Full | ✅ Basic | ✅ Full |
| **Performance** | Medium | High | Medium | High |
| **Complexity** | High | Low | Medium | Medium |
| **Multi-cluster** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |

## Sidecar Injection

### Automatic Injection
```bash
# Label namespace for automatic injection
kubectl label namespace production istio-injection=enabled

# Verify injection
kubectl get namespace -L istio-injection
```

### Manual Injection
```bash
# Inject sidecar manually
kubectl get deployment myapp -o yaml | istioctl kube-inject -f - | kubectl apply -f -

# Linkerd injection
kubectl get deployment myapp -o yaml | linkerd inject - | kubectl apply -f -
```

### Sidecar Configuration
```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    sidecar.istio.io/inject: "true"
    sidecar.istio.io/proxyCPU: "100m"
    sidecar.istio.io/proxyMemory: "128Mi"
spec:
  containers:
  - name: app
    image: myapp:latest
```

## Service Mesh Monitoring

### Istio Monitoring
```bash
# Check Istio components
kubectl get pods -n istio-system

# Access Kiali dashboard
kubectl port-forward -n istio-system svc/kiali 20001:20001

# Access Jaeger tracing
kubectl port-forward -n istio-system svc/jaeger 16686:16686

# Access Grafana
kubectl port-forward -n istio-system svc/grafana 3000:3000
```

### Linkerd Monitoring
```bash
# Check Linkerd status
linkerd check

# Access Linkerd dashboard
linkerd dashboard

# View service metrics
linkerd stat deployments
linkerd top deployments
```

## Troubleshooting

### Common Issues

#### Sidecar Injection Problems
```bash
# Check injection status
kubectl get pods -o jsonpath='{.items[*].spec.containers[*].name}'

# Verify namespace labels
kubectl get namespace -L istio-injection

# Check injection webhook
kubectl get mutatingwebhookconfiguration
```

#### Traffic Routing Issues
```bash
# Check virtual services
kubectl get virtualservice

# Verify destination rules
kubectl get destinationrule

# Check Envoy configuration
istioctl proxy-config cluster <pod-name>
istioctl proxy-config listener <pod-name>
```

#### mTLS Issues
```bash
# Check peer authentication
kubectl get peerauthentication

# Verify certificates
istioctl proxy-config secret <pod-name>

# Test mTLS connectivity
istioctl authn tls-check <pod-name>.<namespace>
```

## Best Practices

### 1. Gradual Adoption
- Start with observability features
- Implement traffic management incrementally
- Enable security features last
- Test thoroughly in non-production

### 2. Performance Optimization
- Configure appropriate resource limits
- Use sampling for tracing
- Optimize sidecar configuration
- Monitor proxy overhead

### 3. Security
- Enable mTLS gradually
- Implement least privilege policies
- Regular certificate rotation
- Monitor security events

### 4. Operations
- Implement proper monitoring
- Use canary deployments
- Plan for disaster recovery
- Document service dependencies

## Service Mesh vs Alternatives

### Service Mesh vs API Gateway
- **Service Mesh**: East-west traffic, service-to-service
- **API Gateway**: North-south traffic, external clients

### Service Mesh vs CNI
- **Service Mesh**: Application layer (L7)
- **CNI**: Network layer (L3/L4)

### Service Mesh vs Ingress
- **Service Mesh**: Internal service communication
- **Ingress**: External traffic entry point

## Conclusion

Service Mesh provides advanced networking capabilities for microservices, offering traffic management, security, and observability features that are essential for complex distributed applications in Kubernetes environments.