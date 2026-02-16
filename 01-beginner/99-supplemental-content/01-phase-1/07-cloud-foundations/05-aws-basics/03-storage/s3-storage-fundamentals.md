# 📦 S3 & Object Storage Mastery
*Version 1.0 | Architectural Depth in Data Persistence*

---

## 🏛️ Executive Summary
Amazon S3 is the foundation of the cloud's data layer. This guide details the technical consistency models, security mechanisms, and cost-optimization tiers that enable petabyte-scale storage with 11 nines of durability.

---

## 🚀 The "DevOps Why"
DevOps and SRE teams use S3 for **State Storage** (Terraform), **Artifact Storage** (Docker images, Build assets), and **Logs**. Understanding the difference between Storage Tiers can reduce an infrastructure bill by 90% while maintaining required compliance.

---

## 🏗️ Core Architecture: Consistency & Durability
<img src="https://raw.githubusercontent.com/Ganil151/Devops/main/01-Beginner/01-Phase-1/07-Cloud-Foundations/REFERENCE/assets/aws-s3-storage.webp" alt="S3 Storage Architecture" width="800">

### The Consistency Model
- **Strong Consistency**: S3 provides strong read-after-write consistency for PUTS and DELETES of objects in all Regions. After a successful write or delete, any subsequent read or list request will immediately receive the latest version.
- **Durability (11 9's)**: Data is automatically replicated across a minimum of **three physically separated Availability Zones** within a Region.

---

## ⚙️ Storage Tiers & Economics (FinOps)

| Tier | Availability | Min Duration | Use Case |
| :--- | :--- | :--- | :--- |
| **Standard** | 99.99% | N/A | Active data, web assets. |
| **Intelligent-Tiering** | 99.9% | N/A | Unknown or changing patterns. |
| **One Zone-IA** | 99.5% | 30 Days | Non-critical, reproducible data. |
| **Glacier Instant** | 99.9% | 90 Days | Rare access, immediate retrieval. |
| **Glacier Flexible** | 99.9% | 90 Days | Backups (minutes to hours). |
| **Glacier Deep Archive**| 99.9% | 180 Days | 7-10 Year Compliance (12+ hours). |

---

## 🛡️ Security: Policies & ACLs
1. **IAM Policy**: User-level permissions (e.g., "Ganil can only read S3").
2. **Bucket Policy**: Resource-level permissions (e.g., "Only this VPC can access this bucket").
3. **ACLs**: Legacy object-level permissions (Standard is to disable these and use Bucket Policies).
4. **Block Public Access**: A global toggle that overrides all other permissions to prevent data leaks.

---

## 🛠️ CLI Quickstart: Managing Data
```bash
# Upload a file with server-side encryption
aws s3 cp file.txt s3://my-bucket/ --sse AES256

# List files and their storage class
aws s3api list-objects --bucket my-bucket --query 'Contents[].{Key: Key, Class: StorageClass}'
```

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain the technical trade-offs of using S3 Versioning.**
2. **What is "Multipart Upload" and at what file size is it recommended?**
3. **Describe how S3 Lifecycle Policies work with Object Tags.**
4. **Compare S3 Transfer Acceleration vs. Global Accelerator.**
5. **How does S3 Guardrail security work in an AWS Organization (SCPs)?**

---
**Back to Module**: [Storage Overview](./readme.md)
