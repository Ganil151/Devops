# CLI and API Workflows

While VCS is the standard, sometimes you need more flexibility or integration with existing CI/CD tools.

## 1. CLI-Driven Workflow
Use your terminal, but let HCP Terraform do the work.
- **How**: Configure a `cloud {}` block in your HCL.
- **Command**: Run `terraform plan` or `apply` locally.
- **Reality**: The CLI packages your code, sends it to TFC, and streams the output back to your screen. The state and execution remain in the cloud.

```hcl
terraform {
  cloud {
    organization = "my-org"
    workspaces { name = "my-app" }
  }
}
```

## 2. API-Driven Workflow
For advanced automation where you have your own pipeline (Jenkins, GitHub Actions, custom scripts).
- **How**: You use the TFC API to upload a "Configuration Version" (a `.tar.gz` of your code) and trigger a run.
- **Use Case**: When you need to perform complex logic or external checks *before* sending code to Terraform.

## Workflow Comparison

| Workflow | Trigger | Execution | State |
| :--- | :--- | :--- | :--- |
| **VCS** | Git Push/PR | TFC | TFC |
| **CLI** | `terraform apply` | TFC | TFC |
| **API** | API Call | TFC | TFC |

---

## 🏗️ Real-Life Scenario: The Jenkins Integration
**Problem**: A company already has a massive Jenkins pipeline for their Java app and wants to include the infrastructure deployment in the same pipeline.
**Solution**: They use the **API-Driven Workflow**. Jenkins builds the app, then calls the TFC API to upload the HCL code and trigger the infrastructure update. 
**Result**: A single unified pipeline for both App and Infra.

---

## ❓ Interview Questions
1.  **Does the CLI-driven workflow store state locally?**
    *   *Answer*: No. Even though the command is run locally, the state is stored and managed within HCP Terraform.
2.  **When would you choose the API workflow over the VCS workflow?**
    *   *Answer*: When you have a complex CI/CD pipeline that needs to do things TFC can't (like running custom security scans on binaries or integrating with legacy ticket systems) before triggering Terraform.

---

## 🧠 Quiz Snippet (5/50+)
1.  **Which HCL block is used to configure TFC in your code?** (`cloud {}`)
2.  **True/False: In a CLI-driven workflow, the plan runs on your local CPU.** (False - it runs on TFC's remote runner)
3.  **What format does the API workflow use to upload code?** (A `.tar.gz` or `.zip` configuration version)
4.  **Can you use the CLI-driven workflow with local state files?** (No, it forces use of TFC state)
5.  **Which workflow is best for manual, one-off experiments?** (CLI-Driven)
