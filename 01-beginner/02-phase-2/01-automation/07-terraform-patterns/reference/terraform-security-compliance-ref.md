# 🔐 Terraform Security & Compliance Reference
*Version 1.0 | Hardening Infrastructure as Code Pipelines*

---

## 🏛️ Executive Summary
Infrastructure as Code (IaC) is a double-edged sword. While it provides consistency, a single insecure line of code (e.g., `public_access = true`) can be replicated across 100 buckets. Security and Compliance ensure that your IaC follows corporate and legal standards (SOC2/HIPAA) automatically.

---

## 🏗️ Technical Pillars: The Security Stack

### 1. Secret Management (The Anti-Pattern Check)
**Rule**: NEVER commit passwords or API keys to HCL code.
- **Solution 1**: Use **Environment Variables** (`TF_VAR_db_pass`).
- **Solution 2**: Use **Data Sources** to pull secrets from a secure vault (AWS Secrets Manager / HashiCorp Vault) at runtime.

### 2. Policy as Code (Sentinel / OPA)
**Mechanism**: Automated guardrails that scan your `terraform plan` before it is applied.
- **Example Rule**: "No EC2 instance shall be launched without an `Environment` tag."
- **Example Rule**: "Security groups must not allow open traffic on Port 22."

---

## ⚙️ Drift Detection & Remediation
**Drift** is when the actual infrastructure changes outside of Terraform (via the console or CLI).
- **Strategy**: Scheduled CI/CD runs (e.g., once every hour) that execute `terraform plan`.
- **Alerting**: If the plan shows any non-empty diff, notify the SRE team.
- **Auto-Remediation**: In extreme cases, the CI job automatically runs `terraform apply` to revert the manual change.

---

## 🛡️ SRE Global Patterns

| Security Layer | Tooling | Outcome |
| :--- | :--- | :--- |
| **Static Analysis** | `tflint`, `checkov`, `tfsec` | Finds known insecure patterns (e.g., open S3 buckets). |
| **Policy Enforcement**| Sentinel, OPA | Stops non-compliant deployments. |
| **State Encryption** | AWS KMS, Azure KeyVault | Protects sensitive state files. |

---

## 🚀 Troubleshooting Scenario: "Exposed Secrets"
**Scenario**: You accidentally committed an AWS Secret Key to your GitHub repo in `variables.tf`.
- **Immediate Action**: 
  1. Revoke/Rotate the AWS key immediately in the console.
  2. Use a "Git Scrubbing" tool (like BFG Repo-Cleaner) to remove the secret from history.
  3. Update the Terraform code to use an environment variable or data source.

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain why a "State File" is considered a security risk.**
2. **What is the difference between "Pre-Apply" and "Post-Apply" compliance checks?**
3. **Describe how "Workspaces" in Terraform Cloud can be used for security isolation.**
4. **How would you implement "Least Privilege" for a Terraform runner in a multi-account AWS environment?**
5. **Describe the impact of the `provisioner` block on security and idempotency.**

---
**Back to foundations**: [State Management →](./Terraform-State-Management-Ref.md)
