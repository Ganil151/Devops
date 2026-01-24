# Terraform Mastery Challenges 🌍

Master the industry standard for declarative infrastructure provisioning.

---

## 🏆 Challenge 01: The State Manager
**Objective**: Understand and protect the Terraform State (`.tfstate`).

1.  **Requirement**: Initialize a local terraform project.
2.  **Scenario**: A developer accidentally deletes the `terraform.tfstate` file.
3.  **Task**: 
    *   Explain what happens to your resources when the state file is lost.
    *   Research **Remote Backend Configuration** (S3/Azure Blob Storage).
    *   **Action**: Draft a backend configuration block that uses S3 with **State Locking** via DynamoDB.
4.  **Security**: Why should you NEVER commit `.tfstate` files to version control?

---

## 🏆 Challenge 02: Modular Architecture
**Objective**: Build reusable infrastructure components.

1.  **Scenario**: Your company needs to deploy 10 different VPCs for 10 different teams.
2.  **Task**: Create a "VPC Module."
3.  **Requirement**:
    *   The module should take `vpc_cidr` and `environment_name` as **Variables**.
    *   The module should return the `vpc_id` and `public_subnet_ids` as **Outputs**.
4.  **Goal**: Write a `main.tf` in a separate folder that calls this module twice (once for `dev` and once for `prod`).

---

## 🏆 Challenge 03: Provider Mastery (Multi-Cloud)
**Objective**: Managing resources across different clouds.

1.  **Requirement**: Configure both an `aws` provider and a `google` or `azure` provider in one project.
2.  **Task**: Deploy a Storage Bucket in AWS (S3) and an identical bucket in another cloud provider.
3.  **Advanced**: Research **Alias Providers**. How can you deploy resources to two different AWS Regions (e.g., `us-east-1` and `eu-west-1`) in the same script?

---

## 📁 Solutions
Modular templates and Backend configuration snippets are in the `Boilerplates/` directory.
