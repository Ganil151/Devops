# 📊 04: Showback & Chargeback

**[⬅️ Back to Module Index](../readme.md)** | **[Next: FinOps Automation ➡️](../05-automation/readme.md)**

---

# 💸 Scaling Accountability

FinOps is as much a **Cultural** shift as it is a technical one. To scale efficiently, you must move the cloud bill from a "Central IT Headache" to an "Engineering Team Metric." This is achieved through **Showback** and **Chargeback**.

## 🏗️ The Attribution Models

| Model | Stage | Outcome |
| :--- | :--- | :--- |
| **Showback** | 👶 Crawl | **Awareness**. Teams see their costs in a dashboard but don't pay. |
| **Chargeback** | 🏃 Run | **Accountability**. Spend is deducted from the team's actual P&L budget. |

### Why Chargeback matters
When a developer knows that the $5,000 "accident" comes out of their team's project budget (potentially delaying a new hire or a bonus), their behavior changes overnight.

---

## 橋 Allocation: The Shared Cost Bridge

How do you charge for a **$10,000 Enterprise Support Fee**?

1.  **Direct Allocation**: Tagged resources are billed 100% to the owner.
2.  **Proportional Split**: Shared costs are split based on the % of direct spend.
    *   *Example*: If Team A spends 40% of the total AWS bill, they pay 40% of the support fee.
3.  **Fixed Split**: Costs are split equally among all teams (rarely used in mature FinOps).

---

## 📈 The Monthly SRE Review

A professional FinOps report for a team lead should include:

1.  **Total Spend**: This month vs. Last month.
2.  **Unit Metric**: Cost per Active User (is it going up or down?).
3.  **Waste Identification**: List of unattached EBS volumes or under-utilized RDS instances.
4.  **Forecast**: Projected spend for the next 3 months based on current growth.

---

## 📂 Project Structure

Check out the `src/` directory for reporting templates:
- `showback_dashboard.md`: A template for a team-level cost awareness dashboard.
- `allocation_formula.py`: A Python logic block to calculate proportional shared cost splits.

---

## 🧪 Experience the Challenges

**Goal**: Design a Chargeback policy for a multi-tenant K8s cluster.

1.  **Scenario**: A shared EKS cluster costs $2,000. Team Alpha uses 80% of the CPU; Team Beta uses 20%.
2.  **Task**: Calculate the individual bills.
3.  **Critical Thinking**: If Team Beta's pods are small but use 50TB of Data Transfer (while Alpha uses 0), is CPU-only allocation fair? How would you adjust the formula?

---
### 🏁 Continue the Journey
Once the teams are accountable, it's time to automate their optimization in **[05: FinOps-as-Code](../05-automation/readme.md)**.
