# AWS CloudTrail: Governance & Auditing

AWS CloudTrail is a service that enables governance, compliance, operational auditing, and risk auditing of your AWS account. With CloudTrail, you can log, continuously monitor, and retain account activity related to actions across your AWS infrastructure.

---

## 1. Key Concepts

### 📜 Events
An event in CloudTrail is a record of an activity in your AWS account.
- **Management Events**: Provide information about management operations that are performed on resources in your AWS account (e.g., creating an S3 bucket, attaching an IAM policy).
- **Data Events**: Provide information about the resource operations performed on or within a resource (e.g., S3 object-level activity, Lambda function execution activity). These are high-volume and often disabled by default to save cost.
- **Insights Events**: Identify unusual API activity in your account (e.g., a sudden spike in `TerminateInstances` calls).

### 🛣️ Trails
A trail is a configuration that enables delivery of events as log files to an S3 bucket.
- **Single-Region Trail**: Logs events only for a specific region.
- **Multi-Region Trail**: Logs events from all regions to a single S3 bucket (Highly recommended for security).
- **Organization Trail**: Logs events from all accounts in an AWS Organization.

---

## 2. Architecture & Log Flow

1. **User Action**: A user or service makes an API call (via Console, CLI, or SDK).
2. **Detection**: CloudTrail captures the call as an event.
3. **Delivery**:
    - **S3**: Long-term storage and auditing.
    - **CloudWatch Logs**: Real-time monitoring and alerting.
    - **EventBridge**: Triggering automated responses.

---

## 3. Practical Usage & Queries

### Verifying Log Integrity
CloudTrail uses RSA with SHA-256 for signing and SHA-256 for hashing to provide **Log File Integrity Validation**.
```bash
aws cloudtrail validate-logs \
    --trail-arn arn:aws:cloudtrail:us-east-1:123456789012:trail/MainTrail \
    --start-time 2023-12-01T00:00:00Z
```

### Querying with Amazon Athena
Since CloudTrail logs are stored as JSON in S3, Athena is the most efficient way to query them at scale.

**Example: Finding who deleted an S3 bucket**
```sql
SELECT
    eventTime,
    userIdentity.userName,
    sourceIpAddress,
    requestParameters
FROM cloudtrail_logs
WHERE eventName = 'DeleteBucket'
AND eventTime >= '2023-12-01T00:00:00Z'
```

---

## 4. Best Practices
1. **Enable Multi-Region Trails**: Attackers often hide in unused regions.
2. **Enable Log File Integrity Validation**: Prevents audit logs from being tampered with.
3. **Integrate with CloudWatch Logs**: Set up alarms for critical API calls (e.g., `StopLogging`, `UpdateSecurityGroup`).
4. **Encrypt with KMS**: Use a customer-managed key to encrypt CloudTrail logs in S3.

---

**Next Step**: Learn how to monitor resource configurations over time with **[AWS Config](../02-AWS-Config/README.md)**.
