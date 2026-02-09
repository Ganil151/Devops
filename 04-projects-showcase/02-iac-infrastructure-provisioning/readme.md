# Project: Infrastructure as Code (IaC) - Provisioning

**Grade:** Production-Ready | **Primary Tool:** Terraform | **Provider:** AWS

---

## 🌟 Overview
This project showcases a professional approach to Infrastructure as Code (IaC). It is designed as a **Comprehensive Architectural Library** focusing on high availability, security, and scalability on AWS. 

This repository demonstrates the transition from **Atomic Components** (building blocks) to **Production Blueprints** (fully integrated stacks).

## 🚀 Key Achievements
- **Standardized Patterns Library:** Detailed implementations for Networking, Compute (EKS/ECS), Database (RDS/DynamoDB), and Monitoring.
- **SRE-Grade Configuration:** Every module follows the **AWS Well-Architected Framework**, including encryption-at-rest, multi-AZ reliability, and the principle of least privilege.
- **Advanced Networking:** Implementations for complex scenarios like Transit Gateways, Shared VPCs, and Zero-Trust private connectivity.

## 📂 Mapping the Infrastructure
The actual IaC assets are organized across the following global hubs:

### 1. [The Boilerplate Vault](../../07-boilerplates/02-intermediate/terraform/reference.md)
*   **The Patterns Library**: Contains 300+ reusable HCL snippets.
*   **Categories**: VPCs (20+ styles), EKS Clusters, RDS Aurora, and security hardening.

### 2. [Live Architecture](../../03-advanced/04-capstone/terraform/readme.md)
*   **Full-Stack Blueprints**: Real-world integration of the atomic parts into a repeatable environment.

### 3. [Engineering Challenges](./challenges.md)
*   **Knowledge Checks**: 10+ Scenario-based challenges to test IaC and SRE logic.

## 🛡️ Security Pillars
1.  **Zero Trust Integration**: Security Groups are strictly scoped to minimal ports/CIDRs; using OAC for CloudFront/S3 isolation.
2.  **Data Sovereignty**: Mandatory encryption-at-rest (KMS) for all storage layers (S3, RDS, DynamoDB).
3.  **State Safety**: Remote state locking via S3 + DynamoDB to prevent race conditions in team environments.

---
*This repository is part of the DevOps Portfolio - Specializing in Automated Infrastructure Provisioning.*
