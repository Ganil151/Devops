# 🏁 Istio Challenge Solutions

This document provides the implementation manifests for the Istio Service Mesh challenges.

---

## 🏗️ Challenge 01: The "Canary Release" Orchestrator

### VirtualService for 90/10 Split & Header-based Routing

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: canary-service-routing
spec:
  hosts:
  - my-app.prod.svc.cluster.local
  http:
  - match:
    - headers:
        x-user-type:
          exact: tester
    route:
    - destination:
        host: my-app
        subset: v2
  - route:
    - destination:
        host: my-app
        subset: v1
      weight: 90
    - destination:
        host: my-app
        subset: v2
      weight: 10
```

---

## 🛡️ Challenge 02: Zero-Trust mTLS Enforcement

### Strict PeerAuthentication

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default-mtls-strict
  namespace: production
spec:
  mtls:
    mode: STRICT
```

**Discovery**: With `STRICT` mode, any legacy workload or external service attempting to communicate without an Envoy sidecar (or without valid mTLS certificates) will be rejected with a connection error. Use `PERMISSIVE` during migrations.

---

## 📉 Challenge 03: The "Circuit Breaker" Pattern

### DestinationRule with Outlier Detection

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: service-b-circuit-breaker
spec:
  host: service-b
  trafficPolicy:
    connectionPool:
      http:
        http1MaxPendingRequests: 1
        maxRequestsPerConnection: 1
    outlierDetection:
      consecutive5xxErrors: 5
      interval: 10s
      baseEjectionTime: 30s
      maxEjectionPercent: 100
```

**Discovery**: This prevents "Cascading Restarts" by ensuring that if a service is failing, we don't keep hammering it with retries and requests, which would otherwise keep the pods in a crash loop or under high load.
