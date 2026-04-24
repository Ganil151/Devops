# 🔐 Reference: Governance & Cost Keywords

Governance is the "Rules of the Road" and Cost is the "Fuel" of the cloud. These keywords focus on making the cloud sustainable and compliant for enterprise-scale operations.

---

## 🏗️ Governance & Compliance

### `Well-Architected Framework`
*   **Definition**: A set of best practices for designing and operating reliable, secure, efficient, and cost-effective systems in the cloud.
*   **The 6 Pillars**: Operational Excellence, Security, Reliability, Performance Efficiency, Cost Optimization, Sustainability.

### `Shared Responsibility Model`
*   **Definition**: The division of security duties between the Cloud Service Provider (CSP) and the Customer.
*   **Fact**: The CSP is responsible for the security **of** the cloud (global infrastructure); the Customer is responsible for security **in** the cloud (data, IAM, OS).

### `AWS Organizations`
*   **Definition**: An account management service that enables you to consolidate multiple AWS accounts into an organization that you create and centrally manage.
*   **Goal**: Consolidate billing, share resources, and apply global guardrails via SCPs.

---

## 💰 FinOps & Cost Optimization

### `FinOps`
*   **Definition**: The practice of bringing financial accountability to the variable spend model of cloud, enabling engineering, finance, and business teams to make informed trade-offs.

### `Cost Explorer`
*   **Definition**: A tool that enables you to visualize, understand, and manage your cloud costs and usage over time.

### `Right-Sizing`
*   **Definition**: The process of matching instance sizes and types to your workload performance and capacity requirements at the lowest possible cost.

---

## 🎙️ Staff Interview Context

*   **"Who is responsible for patching the Guest OS in an IaaS environment?"**
    *   *Answer*: The **Customer**. Under the Shared Responsibility Model, the cloud provider manages the underlying hardware and hypervisor, but the customer is responsible for the security and maintenance of the operating system they choose to run.
*   **"What are 'Service Control Policies' (SCPs) and how are they different from IAM Policies?"**
    *   *Answer*: SCPs are applied at the **Account or OU level** and act as a "Maximum Permission" filter. Even if an IAM User has `AdministratorAccess`, an SCP can block them from performing specific actions (e.g., `s3:DeleteBucket`).
*   **"How can you automate the shutdown of non-production resources to save money?"**
    *   *Answer*: Using **Instance Tagging** combined with a Lambda script or AWS Instance Scheduler. You can tag resources with `Schedule: business-hours` and have them automatically stop at 6 PM and start at 8 AM.
*   **"Explain the benefit of 'CloudTrail' for an SRE."**
    *   *Answer*: CloudTrail provides a complete audit log of every API call made in the account. This is essential for troubleshooting "Who changed the security group?" incidents and for security investigations.
