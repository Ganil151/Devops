# AWS RDS Architectural Patterns

This directory contains 20 common Relational Database Service (RDS) patterns for AWS using Terraform. RDS provides managed database services that handle routine tasks like hardware provisioning, database setup, patching, and backups.

## 📂 RDS Types Overview

| # | Type | Description | File |
|---|------|-------------|------|
| 1 | **Basic MySQL** | Standard single-instance MySQL setup. | `01-basic-mysql.tf` |
| 2 | **Postgres Instance** | Basic PostgreSQL configuration. | `02-postgres-instance.tf` |
| 3 | **Aurora MySQL** | High-performance distributed Aurora cluster. | `03-aurora-mysql.tf` |
| 4 | **Aurora Postgres** | Managed Aurora PostgreSQL cluster. | `04-aurora-postgres.tf` |
| 5 | **Multi-AZ (HA)** | High Availability with synchronous standby. | `05-multi-az-instance.tf` |
| 6 | **Read Replica** | Horizontal read scaling with secondary instances. | `06-read-replica.tf` |
| 7 | **Storage Autoscaling** | Automatically expands storage as data grows. | `07-storage-autoscaling.tf` |
| 8 | **Performance Insights** | Visualizes database load for troubleshooting. | `08-performance-insights.tf` |
| 9 | **Enhanced Monitoring** | OS-level metrics with 1-second granularity. | `09-enhanced-monitoring.tf` |
| 10 | **Parameter Group** | Tuning database-level engine settings. | `10-parameter-group.tf` |
| 11 | **Option Group** | Enabling additional features like TDE or LDAP. | `11-option-group.tf` |
| 12 | **Subnet Group** | Defining specific private network placements. | `12-subnet-group.tf` |
| 13 | **RDS Proxy** | connection pooling for Lambda and serverless. | `13-rds-proxy.tf` |
| 14 | **IAM Auth** | Passwordless authentication using IAM roles. | `14-iam-auth.tf` |
| 15 | **Secrets Manager** | Automated credential rotation and management. | `15-secrets-manager.tf` |
| 16 | **Aurora Serverless V2** | Instant scaling based on application usage. | `16-aurora-serverless-v2.tf` |
| 17 | **Snapshot S3 Export** | Offloading data to S3 for long-term retention. | `17-snapshot-s3-export.tf` |
| 18 | **Multi-Region Replica** | Cross-region replication for global DR. | `18-multi-region-replica.tf` |
| 19 | **PITR Recovery** | Extended automated backup retention (35 days). | `19-pitr-recovery.tf` |
| 20 | **Minimalist RDS** | Barebones config for rapid development. | `20-minimalist-rds.tf` |

## 🚀 Key Best Practices
1.  **Never Use Hardcoded Credentials**: Use AWS Secrets Manager or IAM Authentication for production databases.
2.  **Private Subnets Only**: Database instances should almost never be in a public subnet. Use `publicly_accessible = false`.
3.  **Enable Storage Encryption**: Always set `storage_encrypted = true` and use a KMS key.
4.  **Multi-AZ for Prod**: Always enable Multi-AZ for production workloads to ensure high availability.
5.  **Backup Retention**: Configure `backup_retention_period` to at least 7 days for production.

## 🛠 Prerequisites
These files are standalone examples. They require variables such as `var.db_sg_id`, `var.db_subnet_group_name`, and `var.private_subnet_ids` to be available in your module.
