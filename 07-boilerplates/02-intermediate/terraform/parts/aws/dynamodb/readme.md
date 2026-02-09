# AWS DynamoDB Architectural Patterns

This directory contains 20 common DynamoDB patterns for NoSQL database services using Terraform. DynamoDB is a fully managed, multi-region, multi-active database that provides fast and predictable performance with seamless scalability.

## 📂 DynamoDB Patterns Overview

| # | Type | Description | File |
|---|------|-------------|------|
| 1 | **On-Demand** | PAY_PER_REQUEST scaling for variable traffic. | `01-basic-ondemand.tf` |
| 2 | **Provisioned** | Fixed read/write capacity units (WCU/RCU). | `02-provisioned-table.tf` |
| 3 | **GSI** | Global Secondary Index for multi-attribute queries. | `03-global-secondary-index.tf` |
| 4 | **LSI** | Local Secondary Index for alternative sort keys. | `04-local-secondary-index.tf` |
| 5 | **TTL** | Time-To-Live for automatic item expiration. | `05-ttl-enabled.tf` |
| 6 | **PITR Backups** | Point-in-time recovery and continuous backup. | `06-pitr-backups.tf` |
| 7 | **Streams** | capturing item-level changes via Streams. | `07-streams-enabled.tf` |
| 8 | **KMS Encryption** | server-side encryption with custom keys. | `08-kms-encryption.tf` |
| 9 | **Global Table** | Multi-region active-active replication. | `09-global-table.tf` |
| 10 | **Kinesis Destination** | Streaming table updates directly to Kinesis. | `10-kinesis-streaming.tf` |
| 11 | **Autoscaling** | dynamically adjusting capacity based on load. | `11-autoscaling-policy.tf` |
| 12 | **DAX Cluster** | In-memory caching for microsecond latency. | `12-dax-cluster.tf` |
| 13 | **Resource Policy** | Cross-account access control via policies. | `13-resource-policy.tf` |
| 14 | **Session Store** | optimized schema for web session management. | `14-session-store.tf` |
| 15 | **Multi-Tenant** | Composite key strategy for SaaS isolation. | `15-multi-tenant-table.tf` |
| 16 | **Binary Store** | storing raw binary blobs as attributes. | `16-binary-attributes.tf` |
| 17 | **Import Target** | Predefined table with key for S3 data import. | `17-import-s3-config.tf` |
| 18 | **Export Enabled** | Table prepared for full export to S3. | `18-export-s3-enabled.tf` |
| 19 | **S3 Pointer** | Pattern for handling items larger than 400KB. | `19-s3-pointer-pattern.tf` |
| 20 | **Minimalist** | Baseline boilerplate configuration. | `20-minimalist-table.tf` |

## 🚀 Key Best Practices
1.  **On-Demand vs Provisioned**: Use **On-Demand** for new or unpredictable applications. Switch to **Provisioned** once traffic patterns are understood to save costs.
2.  **PITR**: Always enable **Point-In-Time Recovery** for production tables (it's non-disruptive and cheap).
3.  **Global Secondary Indexes**: GSIs have their own capacity (if provisioned) and can be added/removed at any time. LSIs must be created at table creation time.
4.  **Least Privilege**: Use IAM roles and resource-based policies to restrict access at the row or attribute level if necessary.
5.  **TTL for Logs**: Use the TTL feature to automatically purge old logs or telemetry data to keep storage costs low.

## 🛠 Prerequisites
These files describe the DynamoDB resource. Most advanced configurations (like DAX or Autoscaling) require additional IAM roles defined in your infrastructure.
