# Advanced EFS Patterns & Troubleshooting

Master production-grade EFS management with lifecycle automation, cross-region replication, and performance optimization.

## 1. Cost Optimization: Lifecycle Management

EFS can automatically move files that aren't accessed regularly to the **Infrequent Access (IA)** or **Archive** storage classes, reducing costs by up to 92%.

- **Policy**: Set the number of days (e.g., 30 days) of inactivity before a file is transitioned.
- **Transition back**: Files move back to Standard storage upon a read/write operation.

```bash
# Set lifecycle policy to transition files to IA after 30 days
aws efs put-lifecycle-configuration \
    --file-system-id $FILE_SYSTEM_ID \
    --lifecycle-policies "TransitionToIA=AFTER_30_DAYS"
```

## 2. EFS Replication & High Availability

EFS supports automated, continuous replication to another file system in the same or a different AWS Region.
- **Recovery Point Objective (RPO)**: Minutes.
- **Recovery Time Objective (RTO)**: Minutes.

```bash
# Create a replication configuration
aws efs create-replication-configuration \
    --source-file-system-id $FILE_SYSTEM_ID \
    --destinations "Region=us-west-2"
```

## 3. Data Protection: AWS Backup integration

EFS integrates natively with **AWS Backup** for centralized, policy-driven backup management.
- **Point-in-time recovery**: Restore specific files or the entire file system.
- **Retention**: Define how long backups are kept.

## 4. Performance Tuning & Scaling

### Throughput Mode Selection
- **Elastic Throughput**: (Best Practice) Automatically scales based on application activity. Use this for unpredictable workloads.
- **Provisioned Throughput**: Use this when your application requires more throughput than the file system size would normally allow in Bursting mode.

### Mounting Options for Performance
Use the following `mount` options for better performance:
- `rsize=1048576,wsize=1048576`: Maximizes the amount of data transferred in a single network request.
- `hard,timeo=600,retrans=2`: Ensures data integrity and reliable retries.

## 5. Troubleshooting Guide

| Symptom | Probable Cause | Resolution |
| :--- | :--- | :--- |
| **Connection Timeout** | Inbound NFS (Port 2049) blocked | Check EFS Security Group to allow inbound traffic from EC2 SG. |
| **Permission Denied** | Incorrect mount permissions | Ensure `ec2-user` or the target user owns the mount point (`chown`). |
| **Slow Performance** | Using standard Bursting mode | Switch to **Elastic Throughput** or **Provisioned Throughput**. |
| **Mount command fails** | Missing `amazon-efs-utils` | Install the EFS helper or ensure you are using the correct NFSv4 syntax. |
| **Out of Space** | (Rare) Account limits reached | EFS is virtually infinite, but check AWS Service Quotas if migration fails. |

---

## EFS Best Practices Checklist
- [ ] Use **Elastic Throughput** for most production workloads.
- [ ] Enable **Lifecycle Management** to save costs on stale data.
- [ ] Use **IAM Authorization** for EFS (via Access Points) for fine-grained security.
- [ ] Always monitor `BurstCreditBalance` (if using Bursting mode) in CloudWatch.
- [ ] Enforce **Encryption at Rest** using KMS.
