# 🐝 Advanced Networking with Cilium & eBPF

> **"Kubernetes networking by default is insecure and slow. Cilium fixes both."**

In this module, we replace the default Kubernetes network (iptables/kube-proxy) with **eBPF**. This enables us to connect multiple clusters into a single **Mesh** with global service discovery and identity-based security.

---

## 🧭 The eBPF Networking Strategy

### 1️⃣ Kernel-Bypass Networking
Replace slow `iptables` chains with eBPF programs running directly in the kernel:
- **Performance**: 30-50% reduction in packet processing latency.
- **Observability**: Viewing every DNS request and HTTP call (L7 visibility) without sidecars.

### 2️⃣ ClusterMesh (The "Flat Network")
Connecting multiple clusters (e.g., `us-east-1` and `eu-west-1`) into a single routing domain:
- **Global Service Discovery**: A service in EU can talk to `my-service.us-east.svc.cluster.local`.
- **Identity Security**: Enforcing Network Policies based on pod labels (`app=frontend`), not IP addresses.

---

## 📚 Technical Implementation

### 🧪 [Lab: Cilium ClusterMesh Setup](./labs/clustermesh-setup-lab.md)
**Objective**: Connect two Kubernetes clusters (Kind/EKS) and verify pod-to-pod connectivity across boundaries.

---

## 🚀 Principal Architect Pro-Tips

1.  **Dwell time**: eBPF allows you to see exactly *where* latency is introduced (DNS vs. TCP Handshake vs. App Processing). Use **Hubble** to visualize this map.
2.  **Encryption**: Use Cilium's transparent WireGuard encryption for node-to-node traffic. It's performant and requires zero app changes.
3.  **Strict Mode**: Default Deny All. If you don't whitelist it, it shouldn't talk.

---
**Status**: 🐝 eBPF Networking Active
**Next Step**: [ClusterMesh Lab](./labs/clustermesh-setup-lab.md)
