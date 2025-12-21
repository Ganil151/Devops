# Advanced Level: Service Mesh

A Service Mesh is a dedicated infrastructure layer for facilitating service-to-service communications. It adds observabilty, traffic management, and security without changing application code.

## 🎯 Learning Objectives
- Why use a Service Mesh?
- **Istio** vs **Linkerd**.
- Traffic Shifting (Canary).
- mTLS (Mutual TLS).

## 1. Core Features
A sidecar proxy (usually Envoy) acts as an intermediary for all network traffic.

1. **Traffic Management**: Intelligent routing (A/B testing, Canary).
2. **Security**: Zero-trust network. Encryption in transit (mTLS).
3. **Observability**: Golden signals (latency, error rates) for every hop.

## 2. Istio
The most feature-rich mesh.
- **VirtualService**: Defines routing rules.
- **DestinationRule**: Defines policies after routing (load balancing, circuit breaking).

### Example: Traffic Splitting
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: my-service
spec:
  hosts:
  - my-service
  http:
  - route:
    - destination:
        host: my-service
        subset: v1
      weight: 90
    - destination:
        host: my-service
        subset: v2
      weight: 10
```

## 3. Linkerd
"The lightweight service mesh".
- Focuses on simplicity and performance.
- Written in Rust (data plane).
- Easier to install and maintain than Istio.

## 4. When strictly necessary?
- You have 50+ microservices.
- You need deep visibility into service-to-service calls.
- You need end-to-end encryption for compliance.
- You need advanced rollout strategies (canary/blue-green) managed at the network layer.

[Back to Advanced Index](../README.md)
