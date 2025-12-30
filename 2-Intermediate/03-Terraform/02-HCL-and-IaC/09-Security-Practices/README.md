# Security Practices

Security in Terraform is about protecting your state, your credentials, and your cloud resources.

## Core Security Pillars

### 1. State Security
The `.tfstate` file contains secrets in plaintext.
- **Encrypt at Rest**: Use S3 encryption.
- **Access Control**: Limit who can read the state bucket.
- **No Git**: Never commit state files.

### 2. Credential Management
- **Never Hardcode**: Don't put keys in `provider` blocks.
- **Use Roles**: Use IAM Instance Profiles for runners or OIDC for GitHub Actions.
- **Environmental Variables**: Use `TF_VAR_...` or vault integration.

### 3. Least Privilege
Grant Terraform only the permissions it needs. Avoid `AdministratorAccess`.

### 4. Code Scanning
Scan HCL for common mistakes (e.g., broad security groups 0.0.0.0/0).

---

## 🏗️ Real-Life Scenario: The Exposed Database
**Problem**: An engineer created a database and forgot to set the `publicly_accessible` flag to false.
**Solution**: Use a security scanner like **tfsec** in the CI pipeline. It will automatically detect the "High" severity risk and block the deployment until the flag is fixed.

---

## ❓ Interview Questions
1.  **How do you securely handle secrets in Terraform?**
    *   *Answer*: Use a secret manager (AWS Secrets Manager, Vault), pass them as environment variables, and use the `sensitive = true` flag.
2.  **Why is OIDC better than IAM user keys for CI/CD?**
    *   *Answer*: OIDC provides temporary, short-lived credentials and doesn't require storing long-lived "secret keys" in the CI tool.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Is the state file encrypted by Terraform by default?** (No, depends on the backend)
2.  **Which attribute masks output in the console?** (`sensitive = true`)
3.  **Should you use 'AdministratorAccess' for Terraform?** (No, use Least Privilege)
4.  **How do you prevent state locking issues?** (Use a backend that supports locking, like DynamoDB)
5.  **Which tool scans HCL for security risks?** (`tfsec` or `checkov`)
