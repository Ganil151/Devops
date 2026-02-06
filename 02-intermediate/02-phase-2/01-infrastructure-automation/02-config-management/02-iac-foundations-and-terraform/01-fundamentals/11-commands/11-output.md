# terraform output

## 📋 Overview

The `terraform output` command is used to extract the values of output variables from your state file. These values are typically used to share information between different Terraform projects or to provide data to external scripts and users.

---

## 🎯 Purpose

- Retrieving infrastructure details (e.g., Load Balancer DNS, Database Endpoint)
- Exporting data for use in CI/CD pipelines
- Passing information to shell scripts or configuration management (Ansible/Chef)
- Validating that specific resources were created with the correct configurations

---

## 📝 Basic Syntax

```bash
terraform output [options] [NAME]
```

---

## 🚀 Common Usage Examples

### 1. View All Outputs
```bash
terraform output
```
*Displays all outputs defined in your root module.*

### 2. View a Specific Output
```bash
terraform output vpc_id
```

### 3. Machine-Readable Format (JSON)
```bash
terraform output -json
```
*Useful for parsing with tools like `jq`.*

### 4. Raw Output (Scripts)
```bash
terraform output -raw private_key_pem > private.key
```
*Removes quotes and extra characters, ideal for piping to other commands.*

---

## ⚙️ Logic in Code

Outputs are defined using the `output` block in your `.tf` files:
```hcl
output "lb_dns_name" {
  description = "The domain name of the load balancer"
  value       = aws_lb.main.dns_name
}
```

---

## 🛠️ Real-World Scenarios

### Scenario 1: The Cross-Project Handshake
You have a **Network** project and an **Application** project.
1. The Network project outputs `subnet_ids`.
2. The Application project uses the `terraform_remote_state` data source to read those `subnet_ids`.
*This creates a clean separation of concerns.*

### Scenario 2: Post-Deployment Shell Scripts
After Terraform creates a Kubernetes cluster, a script needs the cluster's endpoint to run `kubectl config`.
```bash
ENDPOINT=$(terraform output -raw cluster_endpoint)
kubectl config set-cluster my-cluster --server=$ENDPOINT
```

---

## ⚙️ Important Flags

| Flag | Description | Use Case |
|------|-------------|----------|
| `-json` | Output as valid JSON | Automation & JQ parsing |
| `-raw` | Removes shell formatting/quotes | Sensitive keys & token extraction |
| `-state=path` | Read from a specific state file | Inspecting non-active state files |

---

## ⚠️ Sensitive Outputs

If an output contains a password or private key, you **<mark style="background:#d4b106">must</mark>** mark it as sensitive.
```hcl
output "db_password" {
  value     = aws_db_instance.main.password
  sensitive = true
}
```
*Terraform will hide this value in the CLI output to prevent accidental exposure.*

---

## 🎓 Best Practices

1. **Be Narrative**: Always include a `description` so users know what the output represents.
2. **Minimize Surface Area**: Only output what is strictly necessary for external consumption.
3. **Use JSON for Scripts**: Parsing standard CLI text is brittle; always use `-json` in production scripts.

---

## 📖 Summary

**terraform output** is the "Return Statement" of your infrastructure code. It makes your complex configuration **<font color="#92d050">communicative</font>** and **<font color="#92d050">integratable</font>** with the rest of your tech stack.

---

**[⬅️ Back to Commands README](readme.md)** | **[Previous: terraform show](10-show.md)** | **[Next: terraform workspace](12-workspace.md)**
