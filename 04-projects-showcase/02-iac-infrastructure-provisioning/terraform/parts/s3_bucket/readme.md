# AWS S3 Bucket Architectural Patterns

This directory contains 20 different S3 bucket configurations for Amazon Web Services (AWS) using Terraform. S3 (Simple Storage Service) is the cornerstone of cloud storage, providing scalable object storage for various use cases.

## 📂 S3 Bucket Types Overview

| # | Type | Description | File |
|---|------|-------------|------|
| 1 | **Basic Bucket** | Minimal configuration for general storage. | `01-basic-bucket.tf` |
| 2 | **Versioning** | maintains object history for recovery. | `02-versioned-bucket.tf` |
| 3 | **SSE-S3 Encryption** | Standard AES-256 server-side encryption. | `03-encrypted-sse-s3.tf` |
| 4 | **SSE-KMS Encryption** | Advanced encryption with customer-managed keys. | `04-encrypted-sse-kms.tf` |
| 5 | **Website Hosting** | Configures the bucket for static site hosting. | `05-static-website-hosting.tf` |
| 6 | **Logging Bucket** | Destination for server access logs. | `06-logging-bucket.tf` |
| 7 | **Private (BPA)** | Blocks all public access (Security Best Practice). | `07-private-bucket-bpa.tf` |
| 8 | **Lifecycle Rules** | Automated data aging (Standard -> IA -> Glacier). | `08-lifecycle-bucket.tf` |
| 9 | **Replication** | Cross-Region Replication (CRR) for DR. | `09-replication-bucket.tf` |
| 10 | **Object Lock** | Compliance/WORM protection for objects. | `10-object-lock-bucket.tf` |
| 11 | **Inventory** | Automated reporting of object metadata. | `11-inventory-bucket.tf` |
| 12 | **Intelligent Tiering** | Automated cost optimization based on usage. | `12-intelligent-tiering.tf` |
| 13 | **CORS** | Cross-Origin Resource Sharing for web apps. | `13-cors-bucket.tf` |
| 14 | **Transfer Acceleration** | Optimized global data uploads. | `14-transfer-acceleration.tf` |
| 15 | **Requester Pays** | Shifting download costs to the requester. | `15-requester-pays.tf` |
| 16 | **MFA Delete** | Extra layer of protection for object deletion. | `16-mfa-delete-bucket.tf` |
| 17 | **IP Whitelist** | Restricts access to specific network ranges. | `17-ip-whitelist-bucket.tf` |
| 18 | **Multi-Region** | Global unified endpoint for S3 data. | `18-multi-region-access.tf` |
| 19 | **Event Notifications** | Trigger SNS/SQS/Lambda on object events. | `19-event-notifications.tf` |
| 20 | **Minimalist** | Smallest possible PoC configuration. | `20-minimalist-bucket.tf` |

## 🚀 Key Best Practices
1.  **Unique Naming**: S3 bucket names must be globally unique. Most examples here use a `random_id` suffix.
2.  **Encryption by Default**: Always enable server-side encryption.
3.  **Block Public Access**: Unless hosting a public website, always enable all Public Access Block settings.
4.  **Least Privilege**: Use IAM policies to restrict access to the specific resources needed.
5.  **Lifecycle Management**: Use lifecycle rules to save costs by moving old data to cheaper tiers.

## 🛠 Prerequisites
These files are standalone examples. To run them, ensure you have an active AWS session and Terraform configured.
