# Infrastructure as Code (IaC) - Intermediate

Infrastructure as Code is the practice of managing and provisioning computing infrastructure through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools.

---

## 1. Why IaC?

IaC allows DevOps teams to treat their infrastructure just like their application code—versioned, tested, and automated.
- **Speed & Consistency**: Deploy environments in minutes, not hours.
- **Safety**: Errors can be caught in "Plan" stages before deployment.
- **Efficiency**: Reuse building blocks across multiple projects.

---

## 2. Core Tool: HashiCorp Terraform

This module focuses on **Terraform**, the industry-standard for cloud-agnostic IaC.
- **Provider-based**: Connect to AWS, Azure, GCP, and 1000+ other platforms.
- **State-driven**: Terraform maintains a "State File" which is a map of your real-world resources.
- **Declarative**: Focus on *what* you want the infrastructure to look like, not *how* to build it.

---

## 3. Learning Path

### 🏗️ [Terraform AWS Complete](../../../../../../3-Advanced/02-Phase-2/Part-11-Cloud-Architecture/01-Enterprise-Multi-Cloud/09-Infrastructure-as-Code/terraform-aws-complete.md)
The end-to-end guide to building production infrastructure with Terraform.

---

## 4. Best Practices
- **Remote State**: Store your state file in S3/GCS with locking to enable team collaboration.
- **Module-first Design**: Break your code into reusable modules (e.g., `vpc`, `database`, `eks`).
- **Plan before Apply**: Always review the output of `terraform plan` to understand exactly what will change.
- **Never Hardcode Secrets**: Use variables and integrate with Secrets Manager or Vault.

---
**Advanced Integration**: Learn how to automate IaC in [CI/CD Pipelines](../CI-CD/README.md#6-infrastructure-as-code-iac-integration).