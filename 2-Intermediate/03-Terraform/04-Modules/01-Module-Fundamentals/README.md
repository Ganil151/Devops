# Module Fundamentals

Terraform Modules are the primary way to package and reuse infrastructure configurations.

## What is a Module?
A module is simply a directory containing `.tf` files. Even your main project directory is considered the **Root Module**. Any module called from another is a **Child Module**.

## Key Concepts
- **Abstraction**: Hide complex resource details behind a simple interface.
- **Encapsulation**: Group related resources (e.g., VPC, Subnets, IGW) into one logical unit.
- **Reusability**: Use the same code for Dev, Staging, and Prod by changing input variables.

## Types of Modules
1.  **Root Module**: The top-level directory where you run `terraform apply`.
2.  **Child Module**: A directory or external source called via a `module` block.
3.  **Local Module**: Resides on your local filesystem.
4.  **Remote Module**: Hosted on the Terraform Registry, GitHub, or Bitbucket.

---

## 🏗️ Real-Life Scenario: The Copy-Paste Nightmare
**Problem**: An SRE team manages 50 microservices. Each service has its own S3 bucket and IAM policy. Originally, they copied and pasted the HCL for every service.
**Crisis**: A security audit requires all buckets to have "Public Access Block" enabled.
**Old Way**: The team has to manually update 50 files, risking human error.
**Module Way**: The team creates a `secure_s3` module. They update the module code *once*, and all 50 services inherit the security fix on the next `apply`.

---

## ❓ Interview Questions
1.  **What is the difference between a Root Module and a Child Module?**
    *   *Answer*: The Root Module is the main execution context where Terraform is run. A Child Module is a reusable package called by the Root (or another Child) to deploy specific resources.
2.  **Why would you use a module instead of just resources?**
    *   *Answer*: To avoid code duplication, standardize resource configurations, and simplify the management of large-scale infrastructure.

---

## 🧠 Quiz Snippet (5/20+)
1.  **What is the minimum requirement for a directory to be a module?** (One or more `.tf` files)
2.  **True/False: You can call a module from within another module.** (True - Nested Modules)
3.  **What is the main benefit of "Abstraction" in modules?** (Simplifying the user interface for complex infrastructure)
4.  **Which command downloads remote modules?** (`terraform init` or `terraform get`)
5.  **Where does Terraform store local copies of remote modules?** (The `.terraform/modules` directory)
