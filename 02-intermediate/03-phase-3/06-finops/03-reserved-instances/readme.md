# 📉 03: Reserved Capacity & Savings Plans

**[⬅️ Back to Module Index](../readme.md)** | **[Next: Showback & Chargeback ➡️](../04-showback-chargeback/readme.md)**

---

# 💹 The Art of the Bulk Discount

After you have eliminated waste and right-sized your resources, the next level of FinOps is **Rate Optimization**. This involves committing to a certain amount of usage in exchange for massive discounts (up to 72%).

## 🏗️ Commitment Models: SP vs. RI

| Model | Flexibility | Use Case |
| :--- | :--- | :--- |
| **Savings Plans (SP)** | 🚀 **High**. Automatically applies to any instance family/region. | Most workloads. Great for evolving architectures. |
| **Reserved Instances (RI)** | 🐢 **Low**. Locked to specific instance types or regions. | Rock-stable legacy systems or non-compute services (RDS/ElastiCache). |

### The Savings Plan Advantage
Unlike RIs, **Compute Savings Plans** cover EC2, AWS Fargate, and AWS Lambda. If you move from EC2 to Fargate mid-year, your discount follows you!

---

## 📅 The $10,000 Portfolio Strategy

Don't buy 100% coverage at once. Use a **Dollar-Cost Averaging** approach to commitment.

1.  **Crawl (0-30%)**: Cover your "Always On" core services (Databases, Core VPC infra).
2.  **Walk (30-60%)**: Cover the stable baseline of your production web tier.
3.  **Run (60-80%)**: Fine-tune with instance-specific plans to squeeze the last 5% of savings.

---

## 💰 Payment Options: Cash vs. Discount

| Option | Discount | Cash Flow |
| :--- | :--- | :--- |
| **All Upfront** | 🏆 Highest | High initial capital outlay. |
| **Partial Upfront** | ⚖️ Balanced | Some upfront, some monthly. |
| **No Upfront** | 📉 Lowest | $0 down, fixed monthly bill. (Recommended for most SREs). |

---

## 📊 Key Metrics for Success

If your **Utilization** is 100%, you might be under-committed. If it's 50%, you are wasting money on unused "pre-paid" credit.

*   **Coverage**: % of your total running hours that are discounted. (Target: **70-80%**).
*   **Utilization**: % of your purchased commitment that is actually being used. (Target: **>95%**).

---

## 🧪 Deployment Challenge

**Goal**: Purchase a simulated "No Upfront" savings plan.

1.  Use the `aws ce get-savings-plans-purchase-recommendation` command to see what AWS suggests for your account.
2.  Calculate the monthly commitment for a $0.10/hr plan.
3.  **Critical Thinking**: If your team is planning to migrate from Python (EC2) to Go (Fargate) next month, should you buy an **EC2 Instance Savings Plan** or a **Compute Savings Plan**?

---
### 🏁 Continue the Journey
Proceed to **[04: Showback & Chargeback](../04-showback-chargeback/readme.md)** to learn how to assign these savings to the correct teams.
