# 🧪 Hands-On Labs: Data & Governance

## Lab 1: "The Compliance Enforcer"
**Objective**: Write an automation script to identify and secure unencrypted or public S3 buckets.

### Scenario
Your company’s security policy states that "No S3 bucket shall allow public access." You need to write a script that audits all buckets and enforces this rule.

### Your Tasks
- [ ] Write a Python script using `boto3`.
- [ ] Use `s3_client.list_buckets()` to retrieve all bucket names.
- [ ] For each bucket, check the `PublicAccessBlock` configuration.
- [ ] If public access is not blocked, use `put_public_access_block` to enable all blocks (BlockPublicAcls, IgnorePublicAcls, BlockPublicPolicy, RestrictPublicBuckets).
- [ ] **Bonus**: Log the names of the "remediated" buckets to a CloudWatch Log Group.

---

## Lab 2: "Automated Disaster Recovery (RDS)"
**Objective**: Configure automated backups and simulate a Point-In-Time-Recovery (PITR).

### Scenario
An RDS PostgreSQL database is used for production. You need to ensure it can be restored to any minute within the last 7 days and simulate a recovery process after a "logic error" occurs.

### Your Tasks
- [ ] Launch an RDS instance with "Automated Backups" enabled (retention period >= 1 day).
- [ ] Insert some test data into a table with a timestamp.
- [ ] Wait 10 minutes, then perform a manual deletion of that data.
- [ ] Use the "Restore to Point-In-Time" feature in the console or CLI to create a *new* instance from the state 5 minutes *before* the deletion.
- [ ] Verify the data exists on the new restored instance.

---

## 🏁 Final Project: The Data Fortress
Combine all concepts into a single project:
- Create a multi-tier storage architecture using **S3 Lifecycle Policies**.
- Deploy an **Aurora Global Database** with cross-region read replicas.
- Implement an **AWS Config Rule** that monitors for unencrypted EBS volumes.
- Document the cost-savings of this architecture (FinOps report) vs. a flat "Standard" storage tier.
