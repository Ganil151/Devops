# 🏆 Istio Service Mesh Challenges

Master traffic shifted, resilient communication, and zero-trust security using the Envoy-based sidecar mesh.

---

## 🏗️ Challenge 01: The "Canary Release" Orchestrator
**Objective**: Implement a safe rollout for a mission-critical service.

1.  **Requirement**: A service `v1` is running. You have a new `v2` with updated features.
2.  **Task**: Create an Istio **VirtualService** that:
    *   Routes 90% of traffic to `v1`.
    *   Routes 10% of traffic to `v2`.
3.  **Discovery**: How do you use **Header-based Routing** to send testing team traffic *only* to `v2` regardless of the weight?
4.  **Verification**: Use `kubectl logs` on the `v2` pods to confirm they are receiving the intended subset of traffic.

---

## 🛡️ Challenge 02: Zero-Trust mTLS Enforcement
**Objective**: Secure all service-to-service communication by default.

1.  **Scenario**: Your security audit found that services are communicating via plain text.
2.  **Task**: Create a **PeerAuthentication** resource for the entire namespace.
3.  **Mode**: Set mTLS to `STRICT` mode.
4.  **Discovery**: What happens to non-proxied (legacy) workloads trying to enter the namespace? (Research: `PERMISSIVE` vs `STRICT`).
5.  **Verification**: Use the `istioctl proxy-config secret` command to inspect the certificates on a running application pod.

---

## 📉 Challenge 03: The "Circuit Breaker" Pattern
**Objective**: Prevent cascading failures when a downstream dependency is slow.

1.  **Scenario**: Service B is intermittent. Service A is timing out waiting for it, causing high CPU on Service A.
2.  **Task**: Define a **DestinationRule** on Service B with:
    *   `consecutive5xxErrors`: 5
    *   `interval`: 10s
    *   `baseEjectionTime`: 30s
    *   `maxConnections`: 1
3.  **Goal**: "Trip" the circuit so that Service A returns an immediate error instead of waiting and failing slowly.
4.  **Discovery**: How does this prevent the "Cascading Restart" crisis?

---

## 📁 Solutions
Istio YAML manifests and Gateway configurations are located in the `Boilerplates/` directory.
