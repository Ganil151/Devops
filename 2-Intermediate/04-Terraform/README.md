# Terraform: Infrastructure as Code (IaC)

Terraform is an open-source tool that allows you to define both cloud and on-premise resources in human-readable configuration files that you can version, reuse, and share.

---

## 🏗️ 1. HCL & State Mechanics

Terraform uses **HashiCorp Configuration Language (HCL)** to describe resources. It maintains a `terraform.tfstate` file which is the "Source of Truth" for what is actually deployed in your cloud provider.

## 🛠️ 2. Essential Terraform Commands

### 🚦 The Core Workflow
*When to use: The standard cycle for creating and updating infrastructure.*

```bash
# Initialize the project (Downloads providers)
terraform init

# Preview changes before they happen
terraform plan

# Deploy the infrastructure
terraform apply

# Destroy the infrastructure (Use with caution!)
terraform destroy
```

### 🔍 Inspection and Management
*When to use: Debugging and managing existing state.*

```bash
# List all resources currently in the state file
terraform state list

# Show human-readable output of current state
terraform show

# Import existing resources into Terraform management
terraform import <resource_type>.<name> <id>

# Format code to follow HCL standards
terraform fmt
```

---

## 💡 Terraform Best Practices

- **Never Commit State Files**: Keep `terraform.tfstate` out of Git. Use **Remote Backends** (S3, Azure Blob, Terraform Cloud) for team collaboration.
- **Dry (Don't Repeat Yourself)**: Use **Modules** to package common infrastructure patterns.
- **Variable Documentation**: Always provide `description` and `type` for your variables.
- **Lock Your Versions**: Use a `versions.tf` file to lock provider and Terraform versions.
- **Sensitivity Matters**: Use the `sensitive = true` flag for variables containing passwords or keys to prevent them from appearing in logs.

---

## 🧠 Training & Assessment

### Knowledge Quiz

**1. What happens if you run `terraform apply` on a machine where the `terraform.tfstate` file is missing, but resources already exist in the cloud?**
- A) Terraform automatically detects the resources and updates the state
- B) Terraform tries to create the resources again, likely causing errors
- C) Terraform deletes the resources in the cloud
- D) Terraform fails and asks for the state file

**2. Which command is used to download the provider plugins (like AWS or Azure)?**
- A) `terraform download`
- B) `terraform setup`
- C) `terraform init`
- D) `terraform plan`

**3. In HCL, which file is typically used to store default values for variables?**
- A) `variables.tf`
- B) `terraform.tfvars`
- C) `main.tf`
- D) `outputs.tf`

---

### Real-World Troubleshooting Scenarios

#### Scenario 1: The "Locked State" Deadlock
**Problem:** You try to run `terraform plan`, but it fails with `Error: Error acquiring the state lock`.
**Investigation:**
1.  **Cause:** Another team member is currently running a command, or a previous run crashed without releasing the lock.
2.  **Check:** Ensure no one else is currently applying changes.
**Solution:** If you are *certain* no one is using it, run `terraform force-unlock <LOCK_ID>`.

#### Scenario 2: Resource Drift
**Problem:** Someone manually changed a security group rule in the AWS Console, and now Terraform wants to revert it.
**Investigation:**
1.  **Detection:** `terraform plan` shows a change even though you didn't touch the code.
2.  **The Fix:** You can either let Terraform revert it or update your code to match the manual change.
**Solution:** Run `terraform refresh` to sync the state file with the real world before making your decision.

---

## ✅ Knowledge Check
- [ ] Understand HCL syntax (Resources, Variables, Outputs)
- [ ] Master the Init-Plan-Apply-Destroy workflow
- [ ] Configure Remote Backends (e.g., S3 with DynamoDB locking)
- [ ] Build and use reusable Modules
- [ ] Manage secrets with `tfvars` and Environment Variables

## 🔗 Next Steps
- **[Ansible Integration](../03-Ansible/)** - Configure the servers Terraform deploys.
- **[Terraform Cloud](./Terraform-Cloud/)** - Collaborate with your team.
- **[Advanced AWS Projects](./Aws_Projects/)** - Build production-grade VPCs.

---
*Infrastructure is code. Treat it with the same respect as your application logic.*