# 🏗️ 02: Infrastructure Provisioning

> **"A senior engineer doesn't build servers; they build the factory that builds servers."**

---

## 🏛️ The Provisioning Framework

Provisioning is "Layer 1" (The Foundations). It involves the creation of networks, storage, identity, and compute resources. While Shell can do this via APIs, specialized IaC tools manage the **Dependencies** and **State** for you.

### Dependency Mapping

```mermaid
graph TD
    VPC[VPC Network] --> Subnet[Public Subnet]
    Subnet --> SG[Security Group]
    SG --> Instance[EC2 Instance]
    VPC --> Gateway[Internet Gateway]
    
    Note over VPC,Instance: Terraform builds the VPC first, then subnets, then instances.
```

---

## 🌟 Overview

This module covers the "Architectural Heavyweights" of the DevOps world. We focus on tools that talk directly to Cloud APIs and manage the lifecycle of resources from birth to death.

### Key Tools:
1.  **[01-Terraform](./01-Terraform/README.md)**: The industry standard. Uses HCL (HashiCorp Configuration Language) and is provider-agnostic.
2.  **[11-Pulumi](./11-Pulumi/README.md)**: IaC using real programming languages (Python, Go, Typescript).
3.  **[12-Vendor-Tools](./12-Vendor-Tools/README.md)**: Platform-native tools like AWS CloudFormation, Azure ARM/Bicep, and GCP Deployment Manager.

---

## 🚀 Intermediate Provisioning Patterns

1.  **State Locking**: Ensuring that two engineers don't try to change the same resource simultaneously (using DynamoDB or Consul locks).
2.  **Modularization**: Building "Infrastructure Bricks" (e.g., a standard VPC module) that can be reused across 100 different projects.
3.  **Sensitive Data Management**: Integration with Vault or Secrets Manager to prevent API keys from being stored in the IaC code.

---

## 🏆 Real-World Scenario: The Multi-Account Sandbox

**The Challenge**: A large enterprise needs to give 50 different dev teams their own "Sandbox" environment. Each sandbox must have a specific VPC, a DB, and a fixed budget alert.
**The Solution**: A **Terraform Module** called `enterprise-sandbox`. Instead of writing 50 separate configs, the SRE team wrote one module. New sandboxes are created by simply adding a new block to a `main.tf` file:
```hcl
module "team-alpha-sandbox" {
  source = "./modules/sandbox"
  team_name = "alpha"
  budget_limit = 500
}
```

---

## ❓ Interview Preparation (Provisioning)

1.  **Q: What is 'Terraform State' and why is it sensitive?**
    *A: State is a JSON file that maps your code to real-world resources. It often contains sensitive information (like DB passwords or plain-text private keys) and must be stored securely with encryption at rest.*

2.  **Q: Explain the difference between `terraform plan` and `terraform apply`.**
    *A: `plan` performs a dry-run, showing you what the tool *intends* to do by comparing code to State. `apply` actually executes those changes against the Cloud API.*

---

## 📝 Knowledge Check

1.  **Which command is used to catch resources that were created by hand and bring them under code control?**
    - [ ] a) `terraform sync`
    - [x] b) `terraform import`
    - [ ] c) `terraform capture`

2.  **True or False: Pulumi allows you to use standard loops and conditionals from languages like Python.**
    - [x] True
    - [ ] False

---

## 🔗 Next Steps
Proceed to: **[Server Configuration](../03-Server-Configuration/README.md)** →
