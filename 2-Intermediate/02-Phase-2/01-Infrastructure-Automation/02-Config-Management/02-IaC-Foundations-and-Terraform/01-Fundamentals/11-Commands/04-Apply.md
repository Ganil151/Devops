# terraform apply

## 📋 Overview

`terraform apply` is the command that executes the actions proposed in a Terraform plan. It is the bridge between **<mark style="background:#d4b106">code</mark>** and **<mark style="background:#d4b106">reality</mark>**, creating, updating, or deleting real-world infrastructure resources.

---

## 🎯 Purpose

- Implement infrastructure changes
- Reach the "desired state" defined in your `.tf` files
- Update the state file with the results of operations
- Provide output values defined in the configuration

---

## 📝 Basic Syntax

```bash
terraform apply [options] [PLAN_FILE]
```

---

## 🚀 Common Usage Examples

### 1. Standard Apply (Interactive)
```bash
terraform apply
```
*Prompts for a manual "yes" before proceeding.*

### 2. Apply a Saved Plan (Recommended)
```bash
terraform plan -out=prod.tfplan
terraform apply prod.tfplan
```
*Safe and deterministic. Processes the exact changes reviewed in the plan step.*

### 3. Auto-Approve (Automation)
```bash
terraform apply -auto-approve
```
*Bypasses the interactive prompt. Use only in CI/CD or trusted environments.*

### 4. Target Specific Resource
```bash
terraform apply -target=aws_instance.web_server
```
*Applies changes ONLY to the specified resource and its immediate dependencies.*

---

## ⚙️ Important Flags

| Flag | Description | Use Case |
|------|-------------|----------|
| `-auto-approve` | Skips interactive confirmation | CI/CD Pipelines |
| `-compact-warnings` | Slims down warning output | Cleaner terminal logs |
| `-parallelism=n` | Limit concurrent operations (default 10) | Avoiding API Rate Limits |
| `-var-file=file` | Pass environment variables | Prod vs Dev deployments |
| `-replace=addr` | Force resource recreation | Troubleshooting corrupted resources |

---

## 🛠️ Real-World Scenarios

### Scenario 1: The "Terraform Sandwich" (Daily Workflow)
1. **<mark style="background:#d4b106">terraform plan -out=run.plan</mark>**
2. Team reviews the plan (Security, Cost, Architecture)
3. **<mark style="background:#d4b106">terraform apply run.plan</mark>**

### Scenario 2: Emergency Replacement
When an EC2 instance is behaving strangely but Terraform thinks it's fine.
```bash
terraform apply -replace="aws_instance.app_server"
```
*Terraform will destroy and recreate just that specific instance during the apply.*

---

## ⚠️ Common Errors & Solutions

### Error: "Resource already exists"
**Cause**: The resource was created manually or by another Terraform state.
**Solution**: Use **<mark style="background:#d4b106">terraform import</mark>** to bring it under management or delete the manual resource.

### Error: "Access Denied"
**Cause**: IAM credentials don't have permission to create the resource.
**Solution**: Verify the IAM user/role being used has the necessary AWS permissions.

### Error: "State Lock"
**Cause**: Another user or process is currently running Terraform.
**Solution**: Wait for them to finish, or use `terraform force-unlock` if a crash occurred.

---

## 🎓 Best Practices

1. **Never skip the Plan**: Always use a plan file in production.
2. **Review the Summary**: Before typing "yes", check the count: `Plan: X to add, Y to change, Z to destroy`.
3. **Backup State**: Ensure your backend (S3/GCS) has versioning enabled before complex applies.

---

## 📖 Summary

**terraform apply** is where the magic happens. It transforms your text-based configuration into live infrastructure. Use it with precision and always trust your **<font color="#92d050">plan</font>** before you **<font color="#92d050">apply</font>**.

---

**[⬅️ Back to Commands README](README.md)** | **[Previous: terraform plan](03-Plan.md)** | **[Next: terraform destroy](05-Destroy.md)**
