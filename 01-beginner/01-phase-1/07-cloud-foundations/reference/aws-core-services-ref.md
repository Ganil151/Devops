# 🟠 AWS Core Services: The Cloud Giant
*Version 1.0 | Mastering the Standard for Cloud Infrastructure*

---

## 📖 Overview
Amazon Web Services (AWS) is the world's most comprehensive and broadly adopted cloud platform. For DevOps and SREs, mastering AWS is often the primary requirement for modern infrastructure management.

---

## 🏗️ Technical Pillars (Compute)

### EC2 (Elastic Compute Cloud)
**Definition**: Resizable compute capacity in the cloud (Virtual Servers).
**SRE Standard**: Use **Auto Scaling Groups (ASG)** to maintain availability and scale based on load.

### Lambda (Serverless)
**Definition**: Function-as-a-Service (FaaS) that lets you run code without provisioning or managing servers.
**Use Case**: Event-driven automation (e.g., resizing images uploaded to S3).

---

## 🗄️ Storage & Databases

### S3 (Simple Storage Service)
**Definition**: Object storage built to retrieve any amount of data from anywhere.
**Best Practice**: Enable **Versioning** and **Bucket Policies** for security and recovery.

### RDS (Relational Database Service)
**Definition**: Managed SQL service (MySQL, PostgreSQL, etc.).
**Advantage**: Automatic patching, backups, and high-availability (Multi-AZ).

---

## 🌐 Networking & Security

### VPC (Virtual Private Cloud)
**Definition**: A logically isolated section of the AWS Cloud where you can launch AWS resources in a network you define.
**Components**: Subnets, Route Tables, Internet Gateway (IGW).

### IAM (Identity and Access Management)
**Definition**: Securely manage access to AWS services and resources.
**Principle**: Always use the **Principle of Least Privilege (PoLP)**.

---

## 🚀 Advanced Deployment Tools

- **Beanstalk**: Easy PaaS for deploying web apps.
- **ECS/EKS**: Container orchestration (Docker/Kubernetes).
- **CloudFormation**: Infrastructure as Code (IaC) native to AWS.

---

## 💡 SRE Pro-Tips
- **Cost Explorer**: Use tags religiously to track spending across teams and environments.
- **Regions vs AZs**: Design apps across multiple **Availability Zones (AZs)** to survive a data center outage.
- **CloudWatch**: Centralize all logs and metrics here to build your monitoring dashboards.

---
**Next Step**: [Azure Core Services →](./Azure-Core-Services-Ref.md)
