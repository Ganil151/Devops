# AKS: Azure Kubernetes Service

AKS is a managed Kubernetes service on Azure that simplifies deploying, managing, and scaling containerized applications.

---

## 🏗️ Core Features
- **Managed Control Plane**: Microsoft manages the API server and etcd at no cost (Basic tier).
- **Integrated Identity**: Deep integration with **Azure Active Directory (AAD)** for RBAC.
- **Node Pools**: Easily manage different VM sizes and scaling sets.
- **Azure CNI**: Native networking that assigns VNet IP addresses directly to pods.

---

## 🛠️ Basic Operations (Azure CLI)

### 1. Create AKS Cluster
```bash
az aks create \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --node-count 3 \
    --enable-addons monitoring \
    --generate-ssh-keys
```

### 2. Connect to Cluster
```bash
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
```

### 3. Scale Cluster
```bash
az aks scale --resource-group myResourceGroup --name myAKSCluster --node-count 5
```

---

## 🔒 Security Best Practices
1.  **Use Azure AD Integration**: Manage cluster access using your organization's existing identities.
2.  **Network Policies**: Use Azure Network Policies or Calico to restrict pod-to-pod traffic.
3.  **Private Clusters**: Ensure the API server is not exposed to the public internet by using Private AKS.
4.  **Security Center**: Enable Microsoft Defender for Containers to scan for image vulnerabilities.

---
**Next Step**: Learn about **[GKE (Google Kubernetes Engine)](../GKE/README.md)**.
