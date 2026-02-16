# 🎡 AWS EKS (Elastic Kubernetes Service)
*The Enterprise Standard for Managed Kubernetes*

---

## 🏛️ Executive Summary
Amazon EKS is a managed service that eliminates the need to install, operate, and maintain your own Kubernetes control plane on AWS. It provides a highly available and secure environment for running containerized applications at scale, certified conformant with standard Kubernetes.

---

## 🚀 The "DevOps Why"
DevOps engineers choose EKS for **Standardization**. While ECS is easier, EKS provides a vendor-neutral API (Kubernetes) that allows for multi-cloud portability, extensive community tooling (Helm, ArgoCD), and granular control over service-to-service communication via Service Meshes.

---

## 🏗️ Core Architecture
AWS EKS splits the cluster into two logical components:

### 1. The Control Plane (Managed)
AWS manages the API Server, Etcd (data store), and Scheduler across three Availability Zones. This ensures that even if a data center fails, your cluster remains operational.

### 2. The Data Plane (Your Responsibility)
This is where your containers (Pods) actually run. You have two options:
- **Managed Node Groups**: AWS manages the EC2 lifecycle (patching, scaling).
- **Fargate**: No-server compute. You pay per Pod; AWS handles the underlying infrastructure.

---

## 🛠️ CLI Quickstart

### Connect to your cluster:
```bash
aws eks update-kubeconfig --region us-east-1 --name my-cluster
kubectl get nodes
```

### Basic Terraform Snippet (`main.tf`):
```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.27"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    general = {
      instance_types = ["t3.medium"]
      min_size     = 1
      max_size     = 5
    }
  }
}
```

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain the `aws-auth` ConfigMap and its role in EKS security.**
2. **What is the difference between an Ingress Controller and a LoadBalancer service in EKS?**
3. **How does EKS handle Pod-to-Pod communication within a VPC? (AWS VPC CNI).**
4. **When would you choose Fargate over Managed Node Groups for an EKS workload?**
5. **Describe the process of upgrading an EKS cluster with zero downtime.**

---
**Detailed Guide**: [AWS EKS Fundamentals](./aws-eks-fundamentals.md)
