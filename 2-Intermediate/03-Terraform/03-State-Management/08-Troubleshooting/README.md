# Troubleshooting State Issues

Handling common errors like corrupted state, lost locks, and drift.

## Common State Errors

### 1. "Error acquiring state lock"
- **Cause**: Another process is running, or a previous process crashed.
- **Fix**: Check if a colleague is running Terraform. If not, use `terraform force-unlock <ID>`.

### 2. "Resource already exists"
- **Cause**: The resource is in the cloud but NOT in your state. This happens if you manually created it or deleted your state.
- **Fix**: Use `terraform import`.

### 3. "State file out of sync" (Configuration Drift)
- **Cause**: Manual changes were made in the cloud portal.
- **Fix**: Run `terraform plan`. It will show the differences. Run `terraform apply` to overwrite the manual changes and "Pull" the world back to your code.

## Recovery Operations

- **State Pull/Push**: Use these to manually edit the JSON as a last resort.
- **Backend Reconfiguration**: `terraform init -reconfigure` if you've messed up your local `.terraform` directory.

---

## 🏗️ Real-Life Scenario: The Ghost VPC
**Problem**: After an internet outage, Terraform says "Lock ID 123-abc is held by UserX." UserX's computer is off.
**Outcome**: The team is blocked. They verify UserX isn't running anything, find the Lock ID in the error message, and run `terraform force-unlock 123-abc`. Development resumes.

---

## ❓ Interview Questions
1.  **What is "Infrastructure Drift"?**
    *   *Answer*: It's when the real Cloud resources have different settings than what's defined in your IaC code, often caused by manual "hotfixes."
2.  **How do you fix drift?**
    *   *Answer*: By running `terraform plan` to identify the changes and `terraform apply` to sync the state back to the code's desired state.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Which command finds differences between real world and state?** (`terraform plan` or `terraform refresh`)
2.  **Is it safe to delete the `.terraform` folder?** (Yes, as long as you have the code; just run `terraform init` again)
3.  **True/False: `force-unlock` should be the first thing you try.** (False - check with the team first!)
4.  **What level of logging helps debug state issues?** (`TF_LOG=DEBUG`)
5.  **How do you pull remote state to your terminal?** (`terraform state pull`)
