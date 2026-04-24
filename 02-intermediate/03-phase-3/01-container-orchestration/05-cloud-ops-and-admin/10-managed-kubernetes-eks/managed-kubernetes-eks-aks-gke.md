# Missing Sections for Managed Kubernetes (EKS, AKS, GKE)

This file contains the high-fidelity enhancements for the Managed K8s module.

---

## ☁️ The Shared Responsibility Model

In Managed Kubernetes, you pay the cloud provider to manage the "Brain" so you can focus on the "Body".

| Feature | You Manage (User) | Cloud Provider Manages |
| :--- | :--- | :--- |
| **Control Plane** | ❌ (Config only) | ✅ (API, etcd, Scheduler) |
| **Worker Nodes** | ✅ (Scaling, OS) | ❌ (Sometimes via Fargate/Autopilot) |
| **User Access** | ✅ (RBAC, IAM) | ❌ |
| **K8s Upgrades** | ✅ (Click to start) | ✅ (Performing actual update) |

---

## 📊 Cloud Provider Showdown: EKS vs. GKE vs. AKS

| Feature | AWS EKS | Google GKE | Azure AKS |
| :--- | :--- | :--- | :--- |
| **Ease of Setup** | Low (CLI heavy) | **High (Native to GCP)** | Medium |
| **Auth System** | AWS IAM | Google IAM | Microsoft Entra ID |
| **Serverless** | Fargate | Autopilot | Virtual Nodes (ACI) |
| **Control Plane Cost** | $0.10 / hour | Free (1st cluster) | Free (Standard tier) |

---

## 🛠️ The 3 Pillars of Managed K8s Success

1.  **Cluster Auto-scaler**: Automatically adds VM instances when pods are `Pending`.
2.  **IAM Integration**: Authenticating to the cluster using your cloud credentials (no more manual tokens).
3.  **VPC Native Networking**: Pod IPs are part of your cloud VPC, allowing easy talk to RDS or S3.

---

## 📖 Real-World DevOps Story: "The Secret Cost of Cloud Control Planes"

**The Scenario:** A startup created 10 different EKS clusters for "Testing" across different developers. They left them running 24/7 for a month.

**The Result:** At the end of the month, they received a $720 bill *just for the control planes*, even though no pods were running on the nodes. 

**The Lesson:** 
- EKS (and GKE after the 1st cluster) charges a flat fee for the control plane.
- Use **Namespaces** to separate "Dev" environments within a single cluster instead of creating new clusters per team.

---

## 👨‍💻 Interview Preparation (Cloud Architect)

1. **Q: Why would I choose Managed K8s over kubeadm (DIY)?**
   *   *A: Availability (SLA), automated control plane backups, and native integration with cloud services (LoadBalancers, IAM, Storage).*

2. **Q: What is "Fargate" or "Serverless" Kubernetes?**
   *   *A: A mode where you don't manage the worker nodes (VMs) at all. You just provide the Pod spec, and the cloud provider runs it on an invisible, managed fleet.*

3. **Q: How do you handle cluster upgrades in Managed K8s?**
   *   *A: You trigger the Control Plane upgrade in the Console/CLI. Once finished, you must upgrade your Node Groups to match the new version, usually by replacing them with new AMI versions.*

---

## 🧠 Knowledge Check

1. Which cloud provider invented Kubernetes? (Google - GKE)
2. What is the AWS service used for serverless Kubernetes worker nodes? (AWS Fargate)
3. Do you have SSH access to the Control Plane nodes in Managed K8s? (No)
