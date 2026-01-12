# terraform state

## 📋 Overview

The `terraform state` command is used for **<mark style="background:#d4b106">Advanced State Surgery</mark>**. It allows you to manually manipulate the Terraform state file without changing your configuration or real-world infrastructure.

---

## 🎯 Purpose

- Listing resources currently tracked by Terraform
- Renaming resources in state to match code changes
- Removing items from state (forgetting them) without destroying them
- Moving resources between different state files
- Troubleshooting state mismatches

---

## 📝 Basic Syntax

```bash
terraform state <subcommand> [options] [args]
```

---

## 🚀 Common Subcommands & Examples

### 1. `list` (The Explorer)
List every resource currently managed by this state file.
```bash
terraform state list
```

### 2. `show` (The Microscope)
Inspect the detailed attributes of a specific resource in state.
```bash
terraform state show aws_instance.web
```

### 3. `mv` (The Surgeon)
Rename a resource address. This is used when you rename a resource in your `.tf` files but don't want Terraform to destroy and recreate it.
```bash
terraform state mv aws_instance.old_name aws_instance.new_name
```

### 4. `rm` (The Forgetter)
Remove a resource from state. Terraform will "forget" it exists, but the resource **<font color="#92d050">remains alive in the Cloud</font>**.
```bash
terraform state rm aws_s3_bucket.manually_managed
```

---

## 🛠️ Real-World Scenarios

### Scenario 1: Refactoring Code
You moved a resource into a module.
- **Problem**: Terraform thinks the old resource is gone and a new one (inside the module) needs to be created.
- **Solution**:
  ```bash
  terraform state mv aws_instance.web module.web_server.aws_instance.this
  ```
- **Result**: No infrastructure is changed; Terraform now knows the existing resource belongs to the module.

### Scenario 2: Emergency Disconnect
A resource is stuck "deleting" in AWS but preventing your whole pipeline from running.
- **Problem**: Terraform won't move forward because it can't refresh this one broken item.
- **Solution**: `terraform state rm <address>`.
- **Result**: You can now run `terraform apply` for the rest of your app.

---

## ⚙️ Important Considerations

| Aspect | Rule |
|--------|------|
| **Backups** | **<mark style="background:#d4b106">Always</mark>** run `terraform state pull > backup.json` before surgery. |
| **Locking** | State commands will attempt to lock the backend to prevent data corruption. |
| **Integrity** | Removing a resource from state leaves it "orphaned." You must manage it manually or re-import it. |

---

## ⚠️ Common Errors & Solutions

### Error: "Resource not found in state"
**Cause**: Typing error or the resource hasn't been applied yet.
**Solution**: Run `terraform state list` to see the exact addresses.

### Error: "State is locked"
**Cause**: Another user is running a plan/apply/state command.
**Solution**: Wait for the operation to finish or release the lock manually with `force-unlock`.

---

## 🎓 Best Practices

1. **Dry Run**: There is no "undo" for state commands (unless you have a backup).
2. **Consult the Team**: Never perform state surgery without informing other DevOps engineers, as it affects the shared source of truth.
3. **Use for Refactoring**: Use `mv` extensively when cleaning up technical debt or standardizing naming conventions.

---

## 📖 Summary

**terraform state** is the surgeon's scalpel. It is high-risk but high-reward, enabling you to fix misalignments between the cloud and your code without downtime. **<font color="#ff0000">Always backup</font>** before you operate.

---

**[⬅️ Back to Commands README](README.md)** | **[Previous: terraform destroy](05-Destroy.md)** | **[Next: terraform import](07-Import.md)**
