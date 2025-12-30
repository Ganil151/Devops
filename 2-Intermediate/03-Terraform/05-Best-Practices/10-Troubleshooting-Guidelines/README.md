# Troubleshooting Guidelines

How to handle the "Oh No!" moments in Terraform with speed and precision.

## 🛠️ The Troubleshooting Toolbox

### 1. TF_LOG
Enable debug logging to see exactly what the API is doing.
```bash
export TF_LOG=DEBUG
terraform plan
```

### 2. State Recovery
If your state is corrupted or lost:
- Use **S3 Versioning** to restore a previous `terraform.tfstate`.
- Use `terraform state pull` to analyze the JSON manually.

### 3. Manual Intervention (Last Resort)
If a resource is "stuck," you may need to:
1.  Delete it manually in the Cloud Console.
2.  Run `terraform state rm <resource_name>`.
3.  Run `terraform apply` to recreate it properly.

## Common Error Patterns
- **"Cycle detected"**: Resource A depends on B, and B depends on A. **Solution**: Use `data` sources or break the circular dependency.
- **"Provider configuration not found"**: Usually happens after removing a module. **Solution**: Run `terraform init`.

---

## 🏗️ Real-Life Scenario: The Locked State
**Problem**: An automated CI job crashes halfway through an `apply`. Now, every developer who tries to run Terraform gets the error: *"Error acquiring state lock."*
**Fix**: The team verifies that no one else is currently running a job, finds the "Lock ID" in the error message, and runs `terraform force-unlock <ID>`.
**Outcome**: The team is unblocked, but they analyze the CI logs to find out *why* it crashed to prevent it from happening again.

---

## ❓ Interview Questions
1.  **A resource is "stuck" in a deleting state. What do you do?**
    *   *Answer*: First, try to fix the issue in the cloud console. If that fails, remove the resource from the state using `terraform state rm` and then manually clean up the cloud resource.
2.  **How do you find out why a `terraform apply` is taking a long time?**
    *   *Answer*: Use `TF_LOG=TRACE` or `DEBUG` to see the exact API calls and wait times for each resource provider.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Which environment variable enables debug logs?** (`TF_LOG`)
2.  **True/False: `force-unlock` is safe to run while an apply is in progress.** (False - Very dangerous!)
3.  **What does a "Circular Dependency" mean?** (Two or more resources waiting for each other to finish)
4.  **Where do you find the Lock ID?** (In the "Error acquiring state lock" message)
5.  **How do you see a list of all managed resources?** (`terraform state list`)
