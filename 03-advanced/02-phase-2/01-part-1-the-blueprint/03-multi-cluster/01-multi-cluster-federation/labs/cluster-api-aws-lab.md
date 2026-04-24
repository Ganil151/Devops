# 🌐 Lab: Cluster API (CAPI) on AWS

> **Scenario**: You are a Platform Engineer tasked with creating a standardized way to spin up Kubernetes clusters on AWS for 50 development teams.
> **The Mission**: Using **Cluster API (CAPI)**, transform an existing "Management Cluster" (e.g., Kind or Minikube) into a factory that churns out AWS EKS clusters on demand.

---

## 🏗️ The Architecture

1.  **Management Cluster**: Runs the CAPI Controllers.
2.  **Infrastructure Provider (CAPA)**: Translates CAPI objects into AWS API calls (create VPC, EC2, ELB).
3.  **Bootstrap Provider**: Generates Cloud-Init (userdata) to join nodes to the cluster.
4.  **Workload Cluster**: The target Kubernetes cluster running on AWS.

---

## 🛠️ Step 1: Initialize the Management Cluster (Local)

Use `clusterctl` to install the providers on your local Kind cluster.

```bash
# 1. Export AWS Credentials (so the controller can use them)
export AWS_REGION=us-east-1
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_B64ENCODED_CREDENTIALS=$(clusterctl aws encode-credentials)

# 2. Initialize Cluster API with AWS Provider (CAPA)
clusterctl init --infrastructure aws
```

---

## 🛠️ Step 2: Define the Workload Cluster Template

Instead of writing 1000 lines of YAML, generating a template.

```bash
# Generate a cluster definition
clusterctl generate cluster my-capi-cluster \
  --kubernetes-version v1.28.0 \
  --control-plane-machine-count=3 \
  --worker-machine-count=3 \
  > my-capi-cluster.yaml
```

**Key Components in `my-capi-cluster.yaml`:**
- `AWSCluster`: Defines the VPC, Subnets, and Region.
- `AWSMachineTemplate`: Defines the EC2 Instance Type (e.g., `t3.medium`) and SSH keys.
- `KubeadmControlPlane`: Manages the Etcd & API Server scaling.

---

## 🛠️ Step 3: Apply & Watch the Magic

```bash
kubectl apply -f my-capi-cluster.yaml

# Watch the provisioning status
clusterctl describe cluster my-capi-cluster
```

*Wait 10-15 minutes while AWS creates VPCs, NAT Gateways, and EC2s.*

---

## 🛠️ Step 4: Accessing the Child Cluster

The `kubeconfig` for the new cluster is stored as a Secret in the Management Cluster.

```bash
# Retrieve the Kubeconfig
clusterctl get kubeconfig my-capi-cluster > my-capi-cluster.kubeconfig

# Verify access
kubectl --kubeconfig=./my-capi-cluster.kubeconfig get nodes
```

---

## 🚨 Principal Architect Insights: "Infrastructure as Data"

- **Immutable Infrastructure**: If a node is sick, CAPI deletes it and creates a new one. We do not SSH into nodes to fix them.
- **Upgrades**: To upgrade K8s, simply change `version: v1.28.0` to `v1.29.0` in the YAML and apply. CAPI performs a rolling update of the Control Plane and Workers automatically.
- **Cost**: Be careful. A simple CAPI cluster creates a VPC, NAT Gateway, and ELB. The "Idle Cost" is non-zero. Destroy it when you are done!

---
**Module**: Cluster API
**Next Lab**: [Advanced Networking with Cilium](../02-advanced-networking-cilium/readme.md)
