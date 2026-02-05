# MySQL & Amazon RDS Challenges 🐬

Master the management of MySQL in both self-hosted and fully-managed cloud environments.

---

## 🏆 Challenge 01: Slow Query Hunter (AWS RDS)
**Objective**: Leverage CloudWatch to monitor database performance.

1.  **Task**: Enable "Enhanced Monitoring" on an AWS RDS Instance.
2.  **Logic**: Configure the export of **Slow Query Logs** to CloudWatch Logs.
3.  **Action**: Create a "CloudWatch Alarm" that triggers a notification if the average CPU utilization exceeds 80% for 5 minutes.
4.  **Verification**: Take a screenshot of the CloudWatch dashboard showing the metrics.

---

## 🏆 Challenge 02: Multi-AZ Reliability (Disaster Recovery)
**Objective**: Build a system that survives a Data Center failure.

1.  **Requirement**: Configure an AWS RDS Multi-AZ deployment.
2.  **Task**: Initiate a "Manual Failover" (Reboot with Failover).
3.  **Discovery**: 
    *   What happens to the Endpoint DNS?
    *   How long did the downtime last during the switch?
4.  **Architectural Question**: Why is the "Standby" instance NOT accessible for read-only traffic? (Research: Secondary Read Replicas).

---

## 🏆 Challenge 03: The Snapshot Migration
**Objective**: Clone a production database for QA testing.

1.  **Task**: Create a Snapshot of a running RDS instance.
2.  **Action**: Restore this snapshot to a **different** AWS Region.
3.  **Constraint**: The target database must be of a smaller/cheaper instance type (e.g., `db.t3.micro`) to save costs.
4.  **Security**: Explain why it is vital to "Sanitize" (mask) PII data after restoring a production snapshot to a QA environment.

---

## 📁 Solutions
Terraform RDS modules and CloudWatch policy templates are in the `Boilerplates/` directory.
