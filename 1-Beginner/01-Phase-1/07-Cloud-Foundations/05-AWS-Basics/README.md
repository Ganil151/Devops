# AWS Basics: The DevOps Entry Point

Amazon Web Services (AWS) is the world's most comprehensive and broadly adopted cloud platform. This module covers the core services and concepts necessary for any DevOps engineer.

---

## 🏗️ 1. Core Learning Modules

- **[AWS Fundamentals for DevOps](01-Introduction/aws-fundamentals-devops.md)**: A deep dive into CLI, EC2, S3, RDS, and IAM.
- **[VPC & Networking](02-Networking/aws-networking-vpc-guide.md)**: Understanding the backbone of AWS infrastructure.
- **[S3 Storage Deep Dive](../../../../README.md)**: Managing object storage at scale.

## 🛠️ 2. AWS CLI Quick Start
*When to use: Automating cloud resource management from your terminal.*

```bash
# Configure your local environment
aws configure

# List all S3 buckets
aws s3 ls

# List running EC2 instances
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"
```

---

## 💡 AWS Best Practices

- **The Principle of Least Privilege**: Never use the Root account for daily tasks. Create IAM users/roles with only the permissions they need.
- **Enable MFA**: Always enable Multi-Factor Authentication for the Root account and any users with administrative access.
- **Tag Everything**: Use a consistent tagging strategy (e.g., `Environment`, `Owner`, `Project`) to track costs and manage resources.
- **Use Managed Services**: Prefer RDS over managing your own DB on EC2, and Lambda over managing servers for simple scripts.
- **Monitor Costs**: Set up AWS Budgets and Billing Alarms early to avoid surprise bills.

---

## 🧠 Training & Assessment

### Knowledge Quiz

**1. Which AWS service is best suited for storing and serving static website files (HTML, CSS, Images)?**
- A) EC2
- B) RDS
- C) S3
- D) Lambda

**2. What is an AWS "Availability Zone" (AZ)?**
- A) A single data center
- B) One or more discrete data centers with redundant power, networking, and connectivity in an AWS Region
- C) A whole geographic area like "North America"
- D) A backup server

**3. In the Shared Responsibility Model, who is responsible for "Security OF the Cloud" (Hardware, Global Infrastructure)?**
- A) The Customer
- B) AWS
- C) Both
- D) The Internet Service Provider

---

### Real-World Troubleshooting Scenarios

#### Scenario 1: The "Connection Refused" EC2 Instance
**Problem:** You launched an EC2 instance and installed Nginx, but you can't reach the public IP in your browser.
**Investigation:**
1.  **Security Group:** Check the inbound rules. Is port 80 (HTTP) open for `0.0.0.0/0`?
2.  **Public IP:** Does the instance actually have a public IP or Elastic IP?
3.  **VPC Routing:** Is the instance in a public subnet with a route to an Internet Gateway (IGW)?
**Solution:** Ensure Port 80 is open in the Security Group and the instance is in a properly configured public subnet.

#### Scenario 2: S3 "Access Denied"
**Problem:** Your application is trying to upload a file to S3 but gets a 403 Forbidden error.
**Investigation:**
1.  **IAM Policy:** Does the IAM Role/User have `s3:PutObject` permission for that specific bucket?
2.  **Bucket Policy:** Is there a bucket-level policy blocking access?
3.  **S3 Block Public Access:** Are you trying to make the object public in a bucket that has "Block Public Access" enabled?
**Solution:** Grant the necessary IAM permissions and ensure the bucket policy allows the operation.

---

## ✅ Knowledge Check
- [ ] Install and configure the AWS CLI
- [ ] Launch and connect to an EC2 instance
- [ ] Create an S3 bucket and upload/download files
- [ ] Understand IAM Users, Groups, and Roles
- [ ] Navigate the AWS Console to find billing information

---

**Next Steps**: Explore [Advanced AWS Services](../../../../README.md) for EKS, CloudFormation, and more.