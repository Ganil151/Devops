# 💰 FinOps & Cost Engineering: The Unit Economics of Cloud

> **"In the cloud, every architectural decision is a financial decision."**

Cloud is a variable expense. FinOps is the cultural practice that brings financial accountability to the variable spend model of cloud, enabling engineering teams to make business-driven trade-offs between speed, cost, and quality.

---

## 🧭 The FinOps Lifecycle

1.  **Inform**: Attributing 100% of spend to teams/products using **Terratag** and mandatory naming conventions.
2.  **Optimize**: Rightsizing resources, scheduling non-prod environments, and mastering **Savings Commitments** (RIs/SPs).
3.  **Operate**: Shifting cost management "Left" by integrating cost into CI/CD pipelines.

---

## 🏗️ The Cost Engineering Toolkit

| Tool | Focus | Difficulty |
|:---|:---|:---|
| **Infracost** | Cost estimation in Pull Requests before you "Apply." | Intermediate |
| **Terratag** | automated tagging for cross-provider cost allocation. | Beginner |
| **AWS Cost Explorer** | Post-billing analysis and anomaly detection. | Intermediate |
| **Karpenter** | Advanced EKS scaling that picks the cheapest instance for the job. | Advanced |

---

## 📚 Technical Implementation Labs

### 💰 [Lab: Shifting Cost Left with Infracost](./labs/infracost-ci-cd-lab.md)
**Objective**: Block a PR if the projected infra cost increase exceeds $500/month.

### 💰 [Lab: Spot Instance Orchestration](./labs/spot-fleet-orchestration.md)
**Objective**: Designing a stateless worker pool that runs 90% cheaper using Spot Instances and interruption handling.

---

## 🚀 Principal Architect Pro-Tips

1.  **Unit Economics over Total Spend**: Don't just look at the $100k bill. Look at the **Cost per Daily Active User**. If users grew 2x but cost grew 1.2x, you are winning.
2.  **Tagging is Law**: If a resource is not tagged with an `Owner` and `Project`, it should be automatically terminated by a Janitor Script within 24 hours.
3.  **The "Cloud-First" Trap**: just because it's cloud-native doesn't mean it's cheap. Managed services (MSK, RDS) have a "Lazy Tax." Measure the cost of self-hosting vs. the cost of management time.
4.  **Incentivize Savings**: The most successful FinOps cultures reward teams that reduce waste. Gamify the reduction of "Orphaned Volumes" and "Idle Load Balancers."

---
**Module**: 02 FinOps
**Next Step**: [Infracost Lab](./labs/infracost-ci-cd-lab.md)
