# GKE: Google Kubernetes Engine

GKE is the industry-leading managed Kubernetes service, benefitting from Google's deep experience in running containerized workloads at scale (Borg).

---

## 🏗️ Core Features
- **Autopilot Mode**: A hands-off experience where Google manages the nodes, scaling, and security.
- **Standard Mode**: Full control over your nodes and cluster configuration.
- **Binary Authorization**: Ensures only trusted container images are deployed.
- **Global VPC**: GKE clusters can leverage Google's global network for low-latency communication.

---

## 🛠️ Basic Operations (gcloud CLI)

### 1. Create GKE Cluster
```bash
gcloud container clusters create my-cluster \
    --zone us-central1-a \
    --num-nodes 3 \
    --enable-autoscaling --min-nodes 1 --max-nodes 10
```

### 2. Connect to Cluster
```bash
gcloud container clusters get-credentials my-cluster --zone us-central1-a
```

### 3. Update Cluster
```bash
gcloud container clusters upgrade my-cluster --zone us-central1-a
```

---

## 🔒 Security Best Practices
1.  **Workload Identity**: Map K8s ServiceAccounts to IAM Service Accounts for secure access to GCP resources.
2.  **Binary Authorization**: Implement a policy to only allow images signed by your build pipeline.
3.  **VPC Native Clusters**: Use Alias IPs for better networking performance and scalability.
4.  **Shielded GKE Nodes**: Use hardened kernel and secure boot to prevent node-level attacks.

---
**Next Step**: Return to the **[Kubernetes Index](../../README.md)**.
