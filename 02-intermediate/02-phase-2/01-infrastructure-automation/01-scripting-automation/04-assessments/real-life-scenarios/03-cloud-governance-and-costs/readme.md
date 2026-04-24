# Cloud Governance and Costs

Cloud bills can spiral out of control. Automation is the only way to enforce tagging policies and clean up orphaned resources at scale.

## 📚 Module Structure
- **[Boilerplates](readme.md)**: `ec2_enforcer.py` (Stopping untagged instances).
- **[CHALLENGES](./challenges.md)**: Orphaned volume cleanup and snapshot pruning.

---

## 🏗️ Scenario: The "Cost Saver" Bot
**Problem**: Developers create EC2 instances for "quick tests" and forget to turn them off on Friday.
**Solution**: A Python script that checks for the `Environment: Prod` tag. If missing, and it is after 6:00 PM on Friday, stop the instance.

---

## 🏗️ Scenario: Orphaned Volumes
**Problem**: Deleting an EC2 instance doesn't always delete the attached EBS volume. These "Available" volumes sit idle and cost money.
**Solution**:
```python
# Pseudo-code
for volume in ec2.volumes.filter(Filters=[{'Name': 'status', 'Values': ['available']}]):
    volume.delete()
```

---

## 📖 Real-World Story: The "Abandoned Project"
A company found a rogue AWS account that was costing $500/month. No one at the company had the password. They realized it was an old project from 2 years ago that was still running.
**Action**: Implemented a "Cloud Governance" account that has read-only access to all sub-accounts to flag untagged resources.
**Result**: Found $50,000/year in idle resources across the company.

---

## ❓ Interview Questions
1. **Name three ways to reduce AWS costs using automation.**
   - *Answer*: 1. Stopping instances after hours; 2. Deleting unattached EBS volumes; 3. Deleting old S3 versions/snapshots.
2. **What is a 'Tagging Policy'?**
   - *Answer*: A set of rules that mandate every resource must have specific tags (e.g., `Owner`, `Project`, `CostCenter`).

---

[Next: API Reliability](../04-api-reliability-and-retries/readme.md)
