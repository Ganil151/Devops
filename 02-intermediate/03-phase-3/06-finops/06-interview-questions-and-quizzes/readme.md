# 🎓 06: Interview Mastery & Knowledge Audit

**[⬅️ Back to Module Index](../readme.md)** | **[Next: Real-Life Scenarios ➡️](../07-real-life-scenarios/readme.md)**

---

# 🎤 Top 20 FinOps Interview Questions

Prepare for your role as a **Cloud Economist** or **Principal SRE**. These questions track your progress from Junior visibility to Architect-level unit economics.

### 🏛️ Tier 1: Fundamentals
1.  **What are the three pillars of the FinOps Lifecycle?**
    *   *Answer*: Inform (Visibility), Optimize (Savings), and Operate (Scaling accountability).
2.  **Differentiate between Showback and Chargeback.**
    *   *Answer*: Showback = Awareness of spend. Chargeback = Deducting from a team's actual budget.
3.  **What is "Right-sizing" and when is the best time to do it?**
    *   *Answer*: Matching resources to utilization. Best done before committing to Savings Plans.
4.  **Explain "Unit Economics" in the cloud.**
    *   *Answer*: Measuring cloud spend against business value (e.g., Cost per Transaction vs. Total Bill).
5.  **What is a "Cloud Anomaly" and how do you detect it early?**
    *   *Answer*: A deviation from normal spend patterns. Detected via ML-based tools like AWS Cost Anomaly Detection.

### 🤖 Tier 2: Optimization & Automation
6.  **How do you manage "Zombie Resources"?**
    *   *Answer*: Automation scripts (like `find_waste.py`) to delete unattached EBS and idle EIPs.
7.  **What is the difference between a Savings Plan and a Reserved Instance?**
    *   *Answer*: Savings Plans (Dollar commitment) are flexible; RIs (Instance commitment) are rigid but sometimes cheaper.
8.  **Explain "Infracost" and its role in a CI/CD pipeline.**
    *   *Answer*: Providing cost estimates for Terraform changes directly in the Pull Request (Shift-Left).
9.  **When is a "Spot Instance" NOT appropriate for a workload?**
    *   *Answer*: For stateful databases, legacy monoliths, or any app that can't handle a 2-minute termination notice.
10. **What is "Storage Tiering"?**
    *   *Answer*: Moving data from S3 Standard to Glacier based on access frequency to save up to 90%.

### 🏗️ Tier 3: Architect Level
11. **How do you allocate the cost of a shared NAT Gateway across 10 teams?**
12. **Describe the "Iron Triangle" of Cloud (Cost, Speed, Quality).**
13. **How do you build a business case for migrating to Graviton instances?**
14. **Explain "Rate Optimization" vs. "Usage Optimization."**
15. **How do you foster a culture of "Shared Accountability" among 200 developers?**

---

# 📝 The FinOps Practitioner Exam (Self-Assessment)

<details>
<summary><b>1. Which pricing model offers up to 90% discount?</b></summary>
**Spot Instances**. (Spare capacity).
</details>

<details>
<summary><b>2. True or False: NAT Gateway data processing is free if it's internal.</b></summary>
**False**. NAT Gateways charge per GB regardless of the target. Use **VPC Endpoints** to make it free/low-cost.
</details>

<details>
<summary><b>3. What is an 'Idle' CPU threshold for a Candidate for Downsizing?</b></summary>
Usually **Average < 10%** and **Peak < 40%** over a 14-day window.
</details>

---

# 🏆 The Final Challenge: The Cost Auditor

**Scenario**: A PR increases the monthly bill by $4,000 because of a new `m5.4xlarge` Redis instance. The developer says "We need it for performance."

**Task**: 
1.  Check the current Redis metrics. If CPU is 2%, what do you say?
2.  Suggest a "Commitment" strategy if this Redis instance is truly permanent.
3.  Write the one-sentence Slack message to the developer to negotiate a right-size.

---
### 🏁 Ready for the real world?
Proceed to **[07: Real-Life Scenarios](../07-real-life-scenarios/readme.md)** to see these principles in production.