# 🚦 Part 3: Networking & Configuration

Connectivity and security are the pillars of production Kubernetes. This part covers how services find each other and how to handle application settings without hardcoding them into images.

---

## 📂 Modules in this Part

### 1. [05-Services-and-Networking](./05-services-and-networking/readme.md)
Stable endpoints for ephemeral pods.
- **Service Types**: ClusterIP, NodePort, and LoadBalancer.
- **Discovery**: Kubernetes DNS and FQDNs.
- **Routing**: Kube-proxy mechanics.

### 2. [06-Ingress-Controllers](./06-ingress-controllers/readme.md)
Layer 7 traffic management.
- **Routing**: Path-based and Host-based routing.
- **Security**: SSL Termination (TLS).
- **Tooling**: NGINX vs. Traefik vs. Istio.

### 3. [07-ConfigMaps-and-Secrets](./07-configmaps-and-secrets/readme.md)
Decoupling configuration from code.
- **ConfigMaps**: Application settings and ENV vars.
- **Secrets**: Encrypted storage for passwords and API keys.
- **Dynamic Updates**: Refreshing configs without pod restarts.

---

## 🚀 Learning Path
1. Start with **Services** to master internal networking.
2. Explore **Ingress** to connect your cluster to the world.
3. Use **ConfigMaps & Secrets** to make your applications portable.

---
[Back to Main Curriculum](../readme.md)
