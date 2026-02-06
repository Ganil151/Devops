# terraform workspace

## 📋 Overview

The `terraform workspace` command allows you to manage multiple distinct state files from a single configuration. Each workspace has its own state, while sharing the same underlying code.

---

## 🎯 Purpose

- Testing the same code in different environments (e.g., `dev` vs `staging`)
- Creating temporary developer sandboxes without affecting shared infrastructure
- Managing multi-region deployments with identical code
- Isolating state for parallel feature branch testing

---

## 📝 Basic Syntax

```bash
terraform workspace <subcommand> [options]
```

---

## 🚀 Common Subcommands & Examples

### 1. `list` (The Census)
See all existing workspaces in this project.
```bash
terraform workspace list
```

### 2. `new` (The Creator)
Create a new workspace and switch to it immediately.
```bash
terraform workspace new dev
```

### 3. `select` (The Switcher)
Move your current context to a different workspace.
```bash
terraform workspace select prod
```

### 4. `show` (The Locator)
Identify which workspace you are currently "in."
```bash
terraform workspace show
```

### 5. `delete` (The Cleaner)
Remove an empty workspace.
```bash
terraform workspace delete temp-sandbox
```

---

## 🛠️ Real-World Scenarios

### Scenario 1: Developer Sandboxes
John and Sarah are working on the same networking module.
- John runs: `terraform workspace new john-tests`
- Sarah runs: `terraform workspace new sarah-tests`
- **Result**: They can both deploy their own VPCs and Subnets simultaneously without their state files ever touching each other.

### Scenario 2: Region Replication
A company wants to deploy the same app to `us-east-1` and `eu-west-1`.
1. `terraform workspace select us-east` -> `terraform apply`
2. `terraform workspace select eu-west` -> `terraform apply`
- **Result**: Identity code, two separate regions, two separate state files.

---

## ⚙️ Logic in Code (The `terraform.workspace` variable)

You can reference the current workspace name in your code to change variable values dynamically:
```hcl
resource "aws_instance" "web" {
  # Use 't3.large' for prod, 't3.micro' for everything else
  instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"

  tags = {
    Environment = terraform.workspace
  }
}
```

---

## ⚠️ Workspaces vs. Multi-Folder Structure

| Feature | Workspaces | Multi-Folder (Dir) Isolation |
|---------|------------|-----------------------------|
| **Best For** | Identical Environments | Prod/Staging/Dev (Production Grade) |
| **Backend** | Shared Backend Bucket | Separate Buckets/Accounts |
| **Isolation** | Logical (weak) | Physical (strong) |
| **Risk** | High (accidental selection) | Low (requires directory change) |

---

## 🎓 Best Practices

1. **Avoid for Production**: Use separate directories (e.g., `envs/prod/`, `envs/dev/`) for critical environments to ensure physical isolation.
2. **Keep the 'default' clean**: It's a common practice to leave the `default` workspace empty to prevent accidental applies.
3. **Use in CI**: Use workspaces to create temporary "ephemeral" environments for pull request testing.

---

## 📖 Summary

**terraform workspace** is the fastest way to achieve state isolation. It is perfect for **<mark style="background:#d4b106">sandboxing and scaling</mark>**, but requires discipline to avoid "Workspace Confusion."

---

**[⬅️ Back to Commands README](readme.md)** | **[Previous: terraform output](11-output.md)** | **[Next: terraform graph](13-graph.md)**
