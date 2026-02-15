# 🧪 Allocation Challenges: Finding the Money

Test your ability to map raw cloud spend to business value.

---

## 🏗️ Challenge 1: The Taxonomy Architect
**Scenario**: You are the Lead SRE for a company with 3 products: "Pay", "Ship", and "Social".
**Task**: 
1.  Design a 5-tag mandatory minimum for every resource.
2.  Explain why `Environment` is not enough for a "Showback" report.
3.  Which tag would you use to differentiate between "Internal Testing" and "External Production" costs?

---

## 🛡️ Challenge 2: Policy Guardrails
**Scenario**: Developers are still creating untagged S3 buckets, leading to $2,000/month in "Unallocated" spend.
**Task**:
1.  Review `src/tagging_policy.json`.
2.  Modify the policy to include `s3:CreateBucket` if it wasn't there (it is, but check the syntax!).
3.  **Critical Thinking**: If you apply this policy today, will it break existing running resources? Why or why not?

---

## 🌉 Challenge 3: The "Hidden NAT" Audit
**Scenario**: Your "Unallocated" cost bucket shows $500/month for `NatGateway-DataTransfer`.
**Task**:
1.  How do you find out WHICH team is sending data through the NAT?
2.  Propose a mechanism to allocate this $500 proportionally across the `Payment` and `Inventory` teams.
3.  **Bonus**: What architectural change would move this cost from $500 to nearly $0?

---

## 📈 Challenge 4: The Showback Report
**Scenario**: The CFO wants to know the "Cost per Transaction" for the "Ship" product.
**Task**:
1.  The "Ship" infrastructure costs $4,000/month.
2.  The product processed 800,000 shipments last month.
3.  Calculate the **Unit Metric**.
4.  If the engineering team optimizes the pods and reduces costs to $3,200, what is the new unit metric?

---
### 🏁 Done?
Once you've master cost mapping, move to **[02: Optimization Strategies](../02-optimization-strategies/readme.md)**.
