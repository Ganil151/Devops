# terraform destroy

## 📋 Overview

`terraform destroy` is the "off switch" for your infrastructure. It removes all objects managed by a particular Terraform configuration. It is effectively the opposite of an apply.

---

## 🎯 Purpose

- Decommissioning temporary testing environments
- Cleaning up resources at the end of a project
- Re-creating an environment from scratch
- **<font color="#ff0000">WARNING:</font>** This operation is destructive and usually permanent.

---

## 📝 Basic Syntax

```bash
terraform destroy [options]
```

---

## 🚀 Common Usage Examples

### 1. Full Environment Deletion
```bash
terraform destroy
```
*Terraform will list all resources it intends to delete and ask for confirmation.*

### 2. Targeted Destruction
```bash
terraform destroy -target=aws_db_instance.test_db
```
*Deletes only the database and any dependent resources.*

### 3. Automated Deletion (Ephemeral Labs)
```bash
terraform destroy -auto-approve
```
*Commonly used in CI/CD pipelines for tear-downs (e.g., deleting a sandbox after tests pass).*

---

## ⚙️ Important Flags

| Flag | Description | Use Case |
|------|-------------|----------|
| `-auto-approve` | Skip the "yes" confirmation | Non-interactive cleanup |
| `-target=addr` | Destroy specific resource | Partial environment cleanup |
| `-refresh=false` | Skip checking cloud state | Speeding up deletion (risky) |

---

## 🛡️ Safeguards vs Destruction

To prevent accidental destruction of critical resources, use these patterns:

### 1. Lifecycle Hooks
```hcl
resource "aws_db_instance" "main" {
  # ...
  lifecycle {
    prevent_destroy = true
  }
}
```
*`terraform destroy` will fail if it attempts to delete this resource.*

### 2. Cloud-Level Locks
Enabling AWS "Deletion Protection" on RDS or Load Balancers adds a second layer of defense that Terraform cannot bypass without an attribute change.

---

## 🛠️ Real-World Scenarios

### Scenario 1: Cost Optimization
A company runs a "Training Lab" every Friday.
- **08:00 AM**: `terraform apply -auto-approve`
- **05:00 PM**: `terraform destroy -auto-approve`
*This saves 70% of weekly infrastructure costs by only paying for active usage.*

### Scenario 2: Failed Deployment Cleanup
If a deployment fails halfway and leaves "orphaned" or broken resources, a `destroy` followed by a fresh `apply` can often reset the environment to a clean state.

---

## ⚠️ Common Errors & Solutions

### Error: "Dependency Violation"
**Cause**: Something outside of Terraform is using a resource (e.g., a manually created EC2 instance using a Terraform-managed Security Group).
**Solution**: Manually delete the external dependency or detach it.

### Error: "Resource still in state"
**Cause**: The cloud API failed to delete the object, but Terraform timed out.
**Solution**: Check the Cloud Console for the error and retry the command.

---

## 🎓 Best Practices

1. **Plan First**: Run `terraform plan -destroy` to see exactly what will be deleted before pulling the trigger.
2. **Use Targets Sparingly**: Targeted destruction can leave orphaned resources or break dependencies.
3. **Double Check the Count**: Always look for the summary: `Plan: 0 to add, 0 to change, 25 to destroy`.

---

## 📖 Summary

**terraform destroy** is powerful and necessary for lifecycle management. Treat it with the same respect as a production deployment. Always verify **<mark style="background:#d4b106">what</mark>** you are destroying before it's gone for good.

---

**[⬅️ Back to Commands README](README.md)** | **[Previous: terraform apply](04-Apply.md)** | **[Next: terraform state](06-State.md)**
