# 🐝 Lab: Cilium ClusterMesh - Connecting the Dots

> **Scenario**: You have Cluster A in `us-east` and Cluster B in `us-west`. 
> **The Problem**: Pods in A need to talk to Pods in B, but creating Ingress/Egress rules for every service is tedious and insecure.
> **The Mission**: Install **Cilium ClusterMesh** to create a flat, identity-aware network across both clusters.

---

## 🏗️ The Prerequisites

1.  **Non-Overlapping Pod CIDRs**: Cluster A (`10.1.0.0/16`) and Cluster B (`10.2.0.0/16`) MUST NOT overlap.
2.  **Shared CA**: Both clusters must trust the same Certificate Authority (CA) for mTLS.
3.  **Connectivity**: The API Servers and Worker Nodes of both clusters must be routeable (VPC Peering / VPN).

---

## 🛠️ Step 1: Installing Cilium (Cluster A & B)

Use the Cilium CLI to install with mesh enabled.

```bash
# Cluster A (Context: kind-cluster-a)
cilium install \
  --cluster-name cluster-a \
  --cluster-id 1 \
  --encryption wireguard \
  --context kind-cluster-a

# Cluster B (Context: kind-cluster-b)
cilium install \
  --cluster-name cluster-b \
  --cluster-id 2 \
  --encryption wireguard \
  --inherit-ca kind-cluster-a \
  --context kind-cluster-b
```

---

## 🛠️ Step 2: Enable ClusterMesh

```bash
# Enable Mesh on Cluster A
cilium clustermesh enable --context kind-cluster-a

# Connect Cluster B to Cluster A
cilium clustermesh connect --context kind-cluster-b --destination-context kind-cluster-a
```

*Wait for `cilium status` to show "ClusterMesh: OK" on both clusters.*

---

## 🛠️ Step 3: Global Service Discovery

Annotate a Kubernetes Service to make it global.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-red-service
  annotations:
    service.cilium.io/global: "true"
spec:
  selector:
    app: red
  ports:
    - port: 80
```

Now, from **Cluster B**, curl the service in **Cluster A**:

```bash
kubectl exec -it my-pod -- curl http://my-red-service.default.svc.cluster.local
```

Cilium will load balance traffic to endpoints in **BOTH** Cluster A and Cluster B if they exist!

---

## 🚨 Principal Architect Insights

- **Latency Awareness**: Be careful with global services. You don't want a request in US-East accidentally hitting a pod in EU-West just because the local pod was restarting. Use **Topology Aware Hints** to prefer local endpoints.
- **Observability**: Use `cilium hubble ui` to visualize the cross-cluster traffic flow. It's magical.
- **Failover**: This architecture allows for seamless region failover. If Cluster A dies, Cluster B picks up the traffic automatically.

---
**Module**: Advanced Networking
**Status**: 🐝 Mesh Active
**Next Step**: [Return to Curriculum](../../../../readme.md)
