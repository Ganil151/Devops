# Security Best Practices

Infrastructure as Code (IaC) is a powerful tool for security, but a single mistake can expose your entire company.

## 🔒 The Three Pillars of TF Security

### 1. No Secrets in Code
- **Never** hardcode passwords, API keys, or certificates.
- **Use**: AWS Secrets Manager, HashiCorp Vault, or environment variables.
- **Tool**: Use `git-secrets` or `trufflehog` to scan for committed keys.

### 2. State File Protection
- Remote state files contain **plain-text secrets**.
- **Secure**: Use S3 with strict IAM policies and KMS encryption.
- **Restrict**: Only the CI/CD pipeline and a few admins should have read access to state.

### 3. Principle of Least Privilege (IAM)
- Your Terraform IAM user should not be an `Administrator`.
- Give it only the permissions it needs for the specific resources in the project.

---

## 🏗️ Real-Life Scenario: The $50k Bitcoin Miner
**Problem**: A junior developer accidentally commits an AWS access key to a public GitHub repo. 
**Outcome**: Within 60 seconds, a bot finds the key, spins up 100 `p3.16xlarge` GPU instances across 10 regions, and starts mining Bitcoin. By the time the bill is caught, the company owes $50,000.
**Lesson**: Use **IAM Roles** for CI/CD runners (like GitHub Actions OIDC) instead of static keys. They have no passwords to steal.

---

## ❓ Interview Questions
1.  **If I mark a variable as `sensitive = true`, is it encrypted in the state file?**
    *   *Answer*: No. It is only masked in the CLI output. It remains plain text in the `terraform.tfstate` file. You must secure the state file bucket itself.
2.  **What is a "Static Analysis" security scan?**
    *   *Answer*: It's a tool (like Checkov or tfsec) that scans your HCL code for security flaws (like an open S3 bucket) *before* you run `terraform apply`.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Which command helps identify security holes?** (`tfsec` or `checkov`)
2.  **True/False: It is safe to store secrets in `terraform.tfvars` if it's gitignored.** (Safe-ish, but better to use a Secret Manager)
3.  **Does Terraform encrypt state at rest by itself?** (No, it relies on the backend provider)
4.  **What is the best way to handle temporary credentials for Terraform?** (IAM Roles / OIDC)
5.  **Should everyone on the dev team have access to the production state bucket?** (No)
