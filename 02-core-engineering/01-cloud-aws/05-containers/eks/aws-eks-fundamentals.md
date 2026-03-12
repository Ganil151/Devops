# 🎡 AWS EKS Fundamentals Guide
*Version 1.0 | Deep-Dive into Managed Kubernetes Architecture*

---

## 🏗️ Technical Architecture
<img src="https://raw.githubusercontent.com/Ganil151/Devops/main/01-Beginner/01-Phase-1/07-Cloud-Foundations/REFERENCE/assets/eks-architecture.webp" alt="EKS Architecture Diagram" width="800">

### The Control Plane Mechanics
The EKS Control Plane consists of the Kubernetes API server and the `etcd` database. AWS runs these across **three Availability Zones** (AZs) automatically. If an AZ goes down, the Control Plane stays up.
- **Control Plane Logging**: You can enable Amazon CloudWatch logs for the API server, audit logs, and scheduler to debug cluster-level issues.

---

## ⚙️ Data Plane Comparison: Fargate vs. EC2

| Feature | Fargate (Serverless) | EC2 Managed Nodes |
| :--- | :--- | :--- |
| **Management** | AWS handles patching/scaling. | You manage instance types. |
| **Pricing** | Per Pod (vCPU/RAM per second). | Per EC2 Instance (hourly). |
| **Scaling** | Vertical/Horizontal Pod Autoscaling. | Cluster Autoscaler (VM level). |
| **Use Case** | Variable workloads, small pods. | High-perf, cost-stable clusters. |

---

## 💰 Pricing & Tiers
- **Cluster Fee**: AWS charges **$0.10 per hour** per EKS cluster. This covers the managed Control Plane.
- **Infrastructure Cost**: You pay for the underlying EC2 instances (Managed Nodes) or the Fargate resources consumed by your Pods.
- **Data Transfer**: Standard AWS data transfer rates apply for traffic moving into/out of the cluster and across AZs.

---

## 🛡️ Performance Tuning & Quotas

### Performance Best Practices
1. **AWS VPC CNI**: By default, Pods get real IP addresses from your VPC. Ensure your subnets have large enough CIDR blocks (e.g., /20).
2. **Resource Requests/Limits**: Always define `resources: requests` to help the scheduler place pods and `limits` to prevent OOM (Out of Memory) kills.
3. **CoreDNS Tuning**: For high-traffic apps, scale the CoreDNS deployment to handle metabolic burst DNS queries.

### Service Quotas (Limits)
- **Clusters per Region**: Default is 100.
- **Fargate Pods**: Default is 50 concurrent pods per region (request increase via AWS Support).
- **Node Groups**: Max size depends on your EC2 instance limits.

---

## 🧪 Real-World Troubleshooting
**Scenario**: "I deployed my Pod, but it's stuck in `Pending` state."
- **Root Cause**: Check if you have enough worker nodes. If using EC2, the **Cluster Autoscaler** might be failing to provision new nodes due to AWS service limits or IAM permissions.
- **Solution**: Run `kubectl describe pod <name>` and look at the "Events" section. Look for messages like "Insufficient cpu" or "FailedScheduling".

---
**Back to Module**: [EKS Main Overview](./readme.md)
