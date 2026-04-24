# 💰 FinOps & Cloud Economics: Multi-Cloud SOT
*Version 2.0 | The Definitive Financial Operations Reference Table*

---

## 🏛️ Executive Summary
FinOps is a cultural practice that enables organizations to get maximum business value by helping engineering, finance, technology, and business teams to collaborate on data-driven spending decisions. This reference provides a **Single Source of Truth** for comparing costs across AWS, Azure, and GCP.

---

## 🏗️ Multi-Cloud Cost Comparison (Table)

| Feature | AWS Equivalent | Azure Equivalent | GCP Equivalent |
| :--- | :--- | :--- | :--- |
| **Cost Visibility** | AWS Cost Explorer | Azure Cost Management | GCP Billing Reports |
| **Budgeting** | AWS Budgets | Azure Budgets | GCP Budgets & Alerts |
| **Savings Commitment**| Savings Plans | Azure Reservations | Committed Use Discounts (CUD) |
| **Spare Capacity** | Spot Instances | Spot Virtual Machines | Preemptible VM Instances |
| **Detailed Export** | CUR (Cost & Usage Report) | Consumption Usage Details | BigQuery Billing Export |

---

## ⚙️ Purchase Model Economics

### 1. Spot Instances / Preemptible VMs
- **Economics**: Up to 90% discount compared to On-Demand.
- **Provider Behavior**: 
  - **AWS**: 2-minute termination notice.
  - **Azure**: 30-second termination notice.
  - **GCP**: 24-hour maximum runtime for standard Preemptible (Legacy), 30-second notice for modern Spot.

### 2. Committed Use (RI / Savings Plans)
- **1-Year vs 3-Year**: 3-year commitments typically offer 60-70% savings, while 1-year offers 30-40%.
- **Convertibility**: AWS "Convertible RIs" allow changing instance families, while standard RIs are fixed.

---

## 🌐 The data Egress Paradox
Most cloud providers charge **$0.00** to bring data in (Ingress), but up to **$0.09/GB** to send data out to the internet (Egress).
- **SRE Impact**: Large datasets should be stored in the same region as the compute resources to avoid "Internal Data Transfer" fees.

---

## � SRE Practical Scenario
**Troubleshooting Scenario**: "Our AWS bill spiked by $5,000 this month."
- **Root Cause Check**: Use the **Cost Explorer** with "Group By: Usage Type".
- **Likely Culprit**: Often **NAT Gateway Data Processing** or **Unattached EBS Snapshots**.
- **Solution**: Implement an automated "Janitor Script" that deletes snapshots older than 30 days and removes unassociated Elastic IPs.

---

## 🛡️ Interview "Deep-Cut" Questions
1. **Explain the difference between an AWS Savings Plan and a Reserved Instance.**
2. **What is "Unit Economics" in FinOps (e.g., Cost per Transaction)?**
3. **How do Egress charges differ between VPC Peering and Transit Gateway?**
4. **Describe the "Crawl, Walk, Run" maturity model for a FinOps team.**
5. **What is the significance of the "Amortized Cost" vs "Unblended Cost" in billing reports?**

---
**Back to foundations**: [Cloud Computing Models →](./cloud-computing-models-ref.md)
