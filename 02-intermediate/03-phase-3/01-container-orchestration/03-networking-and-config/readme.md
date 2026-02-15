# 🚦 Part 3: Networking & Configuration

Connectivity and security are the pillars of production Kubernetes. This part covers how services find each other and how to handle application settings without hardcoding them into images.

---

## 📂 Modules in this Part

### 1. [05-Services-and-Networking](./05-services-and-networking/readme.md)
Stable endpoints for ephemeral pods.
- **Service Abstraction**: How `kube-proxy` (IPtables vs. IPVS) routes traffic to healthy endpoints.
- **Service Discovery**: Mastering **CoreDNS** and the structure of Internal FQDNs.
- **Internal Security**: Implementation of **Network Policies** for zero-trust microservice isolation.

### 2. [06-Ingress-Controllers](./06-ingress-controllers/readme.md)
The gateway to your cluster (Layer 7).
- **Advanced Routing**: Implementing **Canary Traffic Shifting** and **Sticky Sessions**.
- **Edge Security**: Managing **TLS Certificates** via Cert-Manager and Let's Encrypt.
- **Architectural Choice**: Comparative analysis of **NGINX**, **Traefik**, and **Istio Gateway**.

### 3. [07-ConfigMaps-and-Secrets](./07-configmaps-and-secrets/readme.md)
Decoupling configuration from execution.
- **Configuration Injection**: Volume mounts vs. Environment variables (pros and cons).
- **Intermediate Secret Ops**: Securing traffic via **Sealed Secrets** or **External Secret Operator** (AWS/Vault).
- **Immutable Configs**: Ensuring versioned configuration for stable rollbacks.

---

## 🚀 Learning Path
1. Start with **Services** to master internal networking.
2. Explore **Ingress** to connect your cluster to the world.
3. Use **ConfigMaps & Secrets** to make your applications portable.

---
[Back to Main Curriculum](../readme.md)
