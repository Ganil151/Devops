# Advanced Terraform Challenges 🌍

Master enterprise-grade IaC patterns, custom providers, and CI/CD integration.

---

## 🏆 Challenge 01: Terraform Policy as Code (Sentinel/OPA)
**Objective**: Prevent insecure infrastructure BEFORE it is provisioned.

1.  **Requirement**: A Terraform project deploying an S3 Bucket.
2.  **Task**: Write a policy (using **HCP Sentinel** or **OPA/Rego**) that:
    *   Denies any S3 bucket that is NOT encrypted by default.
    *   Denies any bucket with public read access (`ACL = "public-read"`).
3.  **Lab**: Run `terraform plan` and use the OPA binary to audit the plan JSON file.
4.  **Verification**: Confirm that the insecure bucket is rejected with a clear error message.

---

## 🏆 Challenge 02: The Custom Provider Concept
**Objective**: Understand the internals of the Terraform engine.

1.  **Concept**: Terraform isn't just for Cloud. It's for Anything with an API.
2.  **Task**: Diagram the 4 main functions of an Lifecycle Manager in Go:
    *   `Create`
    *   `Read`
    *   `Update`
    *   `Delete`
3.  **Discovery**: Research how **Terraform Providers** communicate with the Terraform Core via GRPC.
4.  **Goal**: Explain why "State Drift" happens when a resource is renamed outside of Terraform.

---

## 🏆 Challenge 03: Multi-Account Landing Zones
**Objective**: Orchestrate hundreds of AWS accounts using Terraform.

1.  **Scenario**: A corporate merger requires 50 new AWS accounts under one Organization.
2.  **Task**: Use the `aws_organizations_account` resource to automate account creation.
3.  **Logic**: 
    *   Add each account to a specific **OU (Organizational Unit)**.
    *   Automatically provision a cross-account IAM Role named `TerraformExecutionRole`.
4.  **Advanced**: Research **Terragrunt** and how it helps keep multi-account code DRY (Don't Repeat Yourself).

---

## 📁 Solutions
Rego policy files and Terragrunt configuration snippets are in the `Boilerplates/` directory.
