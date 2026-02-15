# 🧪 Optimization Challenges: The Waste Hunter

Sharpen your eyes. These challenges test your ability to spot inefficiencies in a complex cloud environment.

---

## 🏗️ Challenge 1: The "Zombie" Audit
**Scenario**: You have inherited an AWS account with 2,000 EC2 instances.
**Task**: 
1.  Study the `src/find_waste.py` script.
2.  Explain why an "Available" volume is costing money even if it's not "In-Use."
3.  Write a simple shell command that would delete all unattached volumes found by the script.

---

## 📏 Challenge 2: The Right-Sizing Math
**Scenario**: Your web app runs on 10 `m5.xlarge` instances ($0.192/hr each).
*   Avg CPU: 4%
*   Peak CPU: 12%
*   Memory Usage: Always under 4GB.

**Task**:
1.  Review the AWS EC2 Instance Types.
2.  Pick a better instance size for this workload.
3.  Calculate the monthly savings (Assume 730 hours in a month).
4.  Why might you pick a `t3.medium` instead of a `c5.large`?

---

## ⚡ Challenge 3: Spot Fleet Architect
**Scenario**: Your company has a data processing job that runs for 4 hours every night. It can be restarted if it fails.
**Task**:
1.  Defend the decision to use **Spot Instances** for this job to your manager.
2.  Propose a "Spot Instance Interruption" handling strategy.
3.  Calculate the potential savings if On-Demand is $1.00/hr and Spot is $0.20/hr.

---

## 📂 Challenge 4: The S3 Lifecycle
**Scenario**: Your logs bucket `company-logs-prod` has 50TB of data. 90% of it is never accessed after 30 days.
**Task**:
1.  Design an S3 Lifecycle policy.
2.  When should data move to **IA (Infrequent Access)**?
3.  When should it move to **Glacier Deep Archive**?
4.  Total cost in S3 Standard is ~$1,150. What is the estimate after moving 45TB to Deep Archive ($0.00099/GB)?

---
### 🏁 Finished?
Great. You've cut the waste. Now let's learn how to buy what you DO need at a discount in **[03: Reserved Capacity](../03-reserved-instances/readme.md)**.
