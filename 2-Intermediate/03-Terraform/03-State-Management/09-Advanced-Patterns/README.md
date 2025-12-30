# Advanced State Patterns

Handling complex multi-project dependencies and workspace-based workflows.

## 1. Remote State Data Source
This allows one Terraform project to "read" the outputs of another project's state file.
- **Use Case**: A "Web App" project needs to know the `vpc_id` created by a "Networking" project.
```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "company-state"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "app" {
  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_id
}
```

## 2. Workspaces
Workspaces allow you to have multiple instances of state for the same code.
- **Use Case**: Testing a feature branch in its own "copy" of the infrastructure.
```bash
terraform workspace new dev-test
terraform workspace select dev-test
terraform apply
```

---

## 🏗️ Real-Life Scenario: The Decoupled Architecture
**Problem**: The "Database Team" wants to manage RDS, but the "App Team" needs the database endpoint to connect. Neither team wants to share a single giant Terraform project.
**Solution**: The Database Team exposes the endpoint as an `output`. The App Team uses a `terraform_remote_state` data source to read that output dynamically. This keeps the projects "Decoupled"—they can be updated independently!

---

## ❓ Interview Questions
1.  **What is a Remote State Data Source?**
    *   *Answer*: It is a read-only way for one Terraform configuration to fetch information (outputs) from another project's state file.
2.  **What is the "Blast Radius" of a project?**
    *   *Answer*: It's the maximum amount of damage that can be caused by a single mistake. Smaller, decoupled states have a smaller blast radius.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Can a data source modify the remote state it's reading?** (No, it's read-only)
2.  **Which command switches workspaces?** (`terraform workspace select`)
3.  **True/False: Workspaces are the best way to separate Dev and Prod environments.** (No, separate directories are preferred for strict isolation)
4.  **How do you access the current workspace name in HCL?** (`${terraform.workspace}`)
5.  **What is the benefit of splitting state files?** (Faster execution and lower risk/blast radius)
