# Day 3 Lab: Remote State Management with S3 & DynamoDB

## Objective
The goal of today's lab is to migrate your Terraform state from your local machine to a secure, remote backend on AWS. You will implement state locking to prevent concurrent executions from corrupting your infrastructure state.

---

## 🏗️ Task Overview
You are tasked with setting up a production-grade Terraform Backend. This involves:
1. Creating an **S3 Bucket** to store the `terraform.tfstate` file.
2. Creating a **DynamoDB Table** for state locking.
3. Configuring Terraform to use this remote backend.

---

## 🛠️ Requirements

### 1. Infrastructure for the Backend (The "Bootstrap" Phase)
Create a new directory called `backend-infra/` and write Terraform code to:
- Create an **S3 Bucket** with:
  - Global uniqueness in the name.
  - **Versioning Enabled** (Crucial for state history).
  - **Server-Side Encryption (AES256)** enabled.
- Create a **DynamoDB Table** with:
  - Name: `terraform-state-lock` (or similar).
  - Hash Key: `LockID` (Type: `String`).
  - Read/Write Capacity: 5 (or use `PAY_PER_REQUEST`).

### 2. Configure the Remote Backend
Once the infrastructure is deployed, return to your main laboratory directory and update your `terraform {}` block:
- **Backend Type**: `s3`
- **Bucket**: The name of the bucket you created in step 1.
- **Key**: `day-3/terraform.tfstate`
- **Region**: `us-east-1` (or your preferred region).
- **DynamoDB Table**: The table created for locking.
- **Encrypt**: `true`

---

## 🚀 Execution Steps

### Step 1: Deploy Backend Resources
```bash
cd backend-infra/
terraform init
terraform apply -auto-approve
```

> **💡 Pro Tip: What is `-auto-approve`?**
> By default, `terraform apply` shows you a plan and waits for you to type `yes` to confirm. The `-auto-approve` flag skips this interactive prompt and applies the changes immediately. 
> - **Use Case**: This is essential for **CI/CD pipelines** (like Jenkins, GitHub Actions) where no human is present to type "yes".
> - **Warning**: Use with caution! It skips the final manual verification of what is about to be created or destroyed.

### Step 2: Initialize with Migration
Update your provider configuration and run:
```bash
terraform init
```
> **Observation**: Terraform will detect your existing local state and ask if you want to migrate it to S3. Confirm with `yes`.

### Step 3: Verify the Lock
Attempt to run `terraform plan` in two different terminal windows simultaneously.
- **Expected Result**: One terminal should succeed, while the other should throw an error stating that the state is "locked by another process."

---

## ❓ Lab Questions
1. Why is **Versioning** mandatory for an S3 state bucket?
2. What happens to your infrastructure if you delete the `terraform.tfstate` file from S3?
3. How does DynamoDB prevent two team members from applying changes at the same time?

---

## 🔗 References
- [S3 Bucket Module (Beginner Guide)](../../../../../../1-Beginner/1-Beginner-Level/13-Cloud-Foundations/05-AWS-Basics/03-Storage/s3-bucket/README.md)
- [Terraform Backend Documentation](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
