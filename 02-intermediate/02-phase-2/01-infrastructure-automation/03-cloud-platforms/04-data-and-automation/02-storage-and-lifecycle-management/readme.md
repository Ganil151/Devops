# 📦 Storage and Lifecycle Management

Storage in the cloud is more than just a place to put files; it is a programmable, tiered ecosystem designed for extreme durability and cost-efficiency.

![Storage Architecture Placeholder](descriptive-diagram:-a-multi-tiered-storage-bucket-showing-data-flowing-from-standard-to-infrequent-access-to-archive/glacier-based-on-time-based-rules.)

## 🚀 The "DevOps Why": Storage Economics
Storing 10TB of logs in a "Hot" (Standard) tier for a year is a FinOps failure. An Intermediate DevOps engineer automates the movement of data to "Glacier" after a period of inactivity, saving up to 90% in storage costs.

---

## 🏗️ Deep-Dive: Storage Classes (S3/GCS/Blob)

| Tier | Access Pattern | Cost (Storage) | Cost (Retrieval) | Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **Standard / Hot** | Immediate, frequent | Highest | Lowest | Active web assets, DB backups |
| **Infrequent / Cool** | Immediate, but rare | Low | High | Monthly reports, Disaster Recovery |
| **Archive / Glacier**| Delayed (mins to hours)| Lowest | Highest | Regulatory compliance, long-term logs |

### 💰 FinOps Tip: Orphaned Snapshots
Delete orphaned EBS snapshots that are no longer associated with active volumes. Over time, these can account for 20-30% of "zombie" cloud spend.

---

## 🔧 Critical Mechanics

### 1. Versioning and MFA Delete
- **Versioning**: Protects against accidental overwrites. Every change creates a new version ID.
- **MFA Delete**: Adds a layer of security requiring human intervention (hardware MFA) to permanently prune a version.

### 2. Lifecycle Policies
Automated workflows that manage your data's lifecycle without human intervention:
- **Transition Actions**: Move data from Standard to Glacier after 30 days.
- **Expiration Actions**: Permanently delete log files after 365 days.

### 3. Replication
- **CRR (Cross-Region Replication)**: Copying data to a different region for Disaster Recovery or Data Residency compliance.
- **SRR (Same-Region Replication)**: Useful for log aggregation or keeping development and production buckets in sync within the same region.

---

## 🛡️ Consistency Models
- **Strong Consistency**: A read immediately after a write always returns the new data. (Cloud providers have largely moved to this for S3/Blob).
- **Eventual Consistency**: There may be a delay (ms to seconds) before all nodes are updated. Critical for high-scale NoSQL and global replication.

---

## 📂 Section Navigation
- [s3-bucket-policies.md](./s3-bucket-policies.md): IAM vs. Bucket-level permissions.
- [s3-encryption.md](./s3-encryption-sse-kms-vs-sse-s3.md): SSE-S3 vs. SSE-KMS deep-dive.
- [s3-replication.md](./s3-replication.md): Configuring CRR for high availability.
