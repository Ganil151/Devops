# Project: Infrastructure as Code (IaC) - Provisioning

**Grade:** production-Ready | **Primary Tool:** Terraform | **Provider:** AWS

## 🌟 Overview
This project showcases a professional approach to Infrastructure as Code (IaC). It isn't just a collection of scripts, but a **Comprehensive Architectural Library** of over **300+ patterns** designed for high availability, security, and scalability on AWS.

The project is structured to transition from "Atomic Components" (building individual parts) to "Production Blueprints" (fully integrated stacks).

## 🚀 Key Achievements
- **Architectural Patterns Library:** 300+ decoupled Terraform modules covering Networking, Compute, Database, Containers, Messaging, and Monitoring.
- **SRE-Grade Configuration:** Every module follows the **Well-Architected Framework**, including encryption-at-rest, multi-AZ reliability, and principle of least privilege.
- **Enterprise Patterns:** Implementations for complex scenarios like Transit Gateways, EKS with IRSA, RDS Aurora Clusters, and Global DynamoDB Tables.

## 📂 Project Structure
```bash
.
├── terraform/
│   ├── parts/            # The Patterns Library (300+ examples)
│   │   ├── vpcs/         # 20 VPC design patterns
│   │   ├── eks/          # Cluster & Node Group patterns
│   │   ├── security_groups/
│   │   └── ... (16 categories total)
│   └── architecture/     # (In Progress) Full-stack blueprints
└── documentation/        # Best practices and deep-dives
```

## 🛠️ Technology Stack
- **Terraform:** HCL for declarative resource management.
- **AWS Provider:** Leveraging the latest resources (OAC, Transit Gateways, etc.).
- **Remote State:** (Planned) S3 + DynamoDB for state locking and shared truth.

## 🛡️ Security Pillars
1. **Zero Trust Integration:** Security Groups are strictly scoped to minimal ports/CIDRs.
2. **Data Sovereignty:** Mandatory encryption-at-rest for S3, RDS, DynamoDB, and EBS.
3. **Visibility:** Integrated CloudWatch logging (awslogs) and metric filters for anomaly detection.

## 🏁 How to Use
1. **Explore the Library:** Navigate to `terraform/parts/` to find specific resource patterns.
2. **Review Best Practices:** Every service category contains a `readme.md` with operational guidance.
3. **Draft Blueprints:** Combine patterns from the library to build your environment.

---
*This repository is part of the DevOps Portfolio - Specializing in Automated Infrastructure Provisioning.*
