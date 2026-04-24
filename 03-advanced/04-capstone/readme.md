# 🌍 Global Capstone: The Multi-Region Resilience Platform

> **"If it isn't tested, it's broken. If it isn't automated, it's toil. If it isn't observable, it's a mystery."**

This is the **Final Boss** of the Advanced DevOps Curriculum. You will not write a README; you will build a platform. 

You are tasked with designing, deploying, and validating a **Global E-Commerce Platform** that can survive the total loss of an AWS Region while maintaining a strict error budget.

---

## 🏗️ The Architecture Requirements

### 1. Multi-Region Networking (The Mesh)
*   **Topology**: Active-Active deployment across `us-east-1` (Primary) and `eu-west-1` (Secondary).
*   **Connectivity**: Use **AWS Transit Gateway** or **Cilium ClusterMesh** to connect the two regions.
*   **Traffic Routing**: Use **AWS Global Accelerator** to route user traffic to the nearest healthy region.

### 2. The Compute Fleet (The Engine)
*   **Provisioning**: Use **Terraform** or **Cluster API (CAPI)** to provision two identical EKS clusters.
*   **GitOps**: App deployment must be managed by **ArgoCD** or **Flux**, syncing the *same* git repository to both clusters.

### 3. The Microservices App (The Payload)
*   **Workload**: Deploy the [Google Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo) (10+ microservices).
*   **Data**: Redis (Cache) must be replicated. Configuring a global Database (e.g., DynamoDB Global Tables or Aurora Global) is optional but recommended for the "Principal" grade.

---

## 🧪 The "Chaos Day" Deliverable

You must perform and document the following **Chaos Experiments**:

| Experiment | Target | Hypothesis | Success Criteria |
|:---|:---|:---|:---|
| **The "Pod Pop"** | `CheckoutService` | If a pod dies, K8s restarts it. | < 1% Error Rate during 5m test. |
| **The "Zone Block"** | `us-east-1a` | If an AZ goes dark, traffic shifts to 1b/1c. | 0% Downtime (Retries handle it). |
| **The "Region Nuke"** | `us-east-1` | If the region is unreachable, global traffic shifts to `eu-west-1`. | RTO < 5 minutes. |

---

## 💰 The FinOps Audit

*   **Budget**: The entire platform must cost less than **$50/day** to run during the test window.
*   **Optimization**: Use **Spot Instances** for 100% of the stateless worker nodes.
*   **Reporting**: Integrate **Infracost** in your PRs to prove you checked the price before clicking "Apply."

---

## 🏆 Submission Artifacts

1.  **Architecture Diagram**: A high-fidelity diagram (Mermaid or Draw.io) showing traffic flow and failover paths.
2.  **The Code**: A single GitHub repository containing `/terraform`, `/kubernetes`, and `/chaos` specifications.
3.  **The "Post-Mortem"**: A written report of your Chaos Experiments. What broke? How did you fix it?
4.  **The Bill**: A screenshot of your AWS Cost Explorer or Infracost output proving you stayed within budget.

---
**Status**: 🚧 Under Construction by Student
**Prerequisites**: Completion of Phases 1, 2, and 3.
