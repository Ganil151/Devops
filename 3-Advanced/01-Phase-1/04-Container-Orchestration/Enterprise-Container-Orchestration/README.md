# Container Orchestration - Advanced (EKS)

The peak of container management. This module focuses on running production-grade Kubernetes at scale using Amazon Elastic Kubernetes Service (EKS).

---

## 1. Why Kubernetes (EKS)?

Kubernetes is the industry standard for container orchestration. EKS removes the heavy lifting of managing the control plane (Master nodes), allowing you to focus on your applications.

### Key Production Requirements
- **High Availability**: Control plane spread across 3 AZs.
- **Security**: IAM Roles for Service Accounts (IRSA) to give pods native AWS permissions.
- **Scaling**: Horizontal Pod Autoscaler (HPA) and Cluster Autoscaler.

---

## 2. Core Guides

### ☸️ [EKS Production-Ready Guide](aws-eks-production-ready.md)
The roadmap from cluster creation (`eksctl`) to production hardening (Inbound/Outbound traffic, IRSA).

---

## 3. The Kubernetes Workflow

1.  **Develop**: Package your app in a Docker container.
2.  **Publish**: Push the image to [Amazon ECR](../../Intermediate-Level/03-Container-Registry-ECR/README.md).
3.  **Deploy**: Apply YAML manifests or Helm charts to the cluster.
4.  **Expose**: Use the [AWS Load Balancer Controller](aws-eks-production-ready.md#3-networking--load-balancing) to create ALBs/NLBs automatically.

---

## 4. Best Practices
- **Managed Node Groups**: Let AWS handle the OS patching and replacement of your worker nodes.
- **Resource Limits**: Always define CPU and Memory requests/limits for your pods to ensure stability.
- **Networking**: Use the AWS VPC CNI for high performance and deep VPC integration.

---
**Observability**: Monitor your cluster using [Container Insights](../17-Observability-Governance/README.md).
