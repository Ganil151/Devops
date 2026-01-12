# Security Best Practices

**Infrastructure as Code (IaC)** is a double-edged sword. It allows you to build secure infrastructure at scale, but a single logic error or leaked credential can expose your **<font color="#ff0000">entire organization</font>** in seconds. Professional SREs treat security not as an afterthought, but as the foundation of the codebase.

---

## 🛡️ 1. Protecting the State File ("The Keys to the Kingdom")

The `.tfstate` file contains **unencrypted** resource data. Even if you mark a variable as `sensitive`, the plain text value (e.g., your DB Root Password) is stored in the JSON state file.

### A. Encryption at Rest
**Rule**: Never use a local state file for production. Always use a backend with **<font color="#ff0000">Mandatory Encryption</font>**.
*   **S3 Backend**: Always enable Server-Side Encryption (SSE) and Bucket Versioning.

```hcl
backend "s3" {
  bucket     = "my-org-terraform-state"
  key        = "prod/vpc/terraform.tfstate"
  region     = "us-east-1"
  encrypt    = true                 # 🚨 MANDATORY
  kms_key_id = "arn:aws:kms:..."    # Use customer-managed keys for higher security
}
```

### B. Access Isolation
*   **The S3 Bucket**: The state bucket should have a "Deny All" policy for everyone except the **CI/CD Service Role** and a small "Break-Glass" admin group.
*   **Public Access**: Explicitly enable **Block Public Access** on both the bucket and account levels.

---

## 🔑 2. Secrets Management Strategy

**Rule #0**: **<font color="#ff0000">NEVER</font>** commit secrets, API keys, or passwords to Git.

### The "Sensitive" Redaction Flag
Use the `sensitive` property to redact values from CLI logs and terminal output.

```hcl
variable "db_password" {
  type      = string
  sensitive = true  # Prevents password from appearing in 'terraform plan' logs
}
```
*⚠️ **Warning**: This does not protect the value in the state file. It only hides it from human eyes during the run.*

### The Professional Pattern: External Secret Injection
Instead of passing secrets via variables, have Terraform fetch them at runtime from a secure vault.

```hcl
# ✅ Fetching from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = "production/database/master_password"
}

resource "aws_db_instance" "this" {
  # ... other configs ...
  password = data.aws_secretsmanager_secret_version.db_creds.secret_string
}
```

---

## 🔐 3. IAM & The Principle of Least Privilege

Don't deploy infrastructure using the `root` user or an `AdministratorAccess` account.

1.  **Role Assumption**: Configure your Terraform provider to assume a specific, temporary IAM role.
2.  **Scoped Permissions**: If your stack only manages Networking, the role should not have `rds:*` or `iam:*` permissions.
3.  **OIDC for CI/CD**: Use OpenID Connect (e.g., GitHub Actions OIDC) instead of storing long-lived **AWS_ACCESS_KEY_ID** secrets in your CI/CD platform.

```hcl
provider "aws" {
  assume_role {
    role_arn     = "arn:aws:iam::123456789:role/TerraformDeployVPC"
    session_name = "Terraform-CI"
  }
}
```

---

## 🔍 4. Static Analysis (Shift-Left Security)

Integrate security scanning into your developer workflow to catch vulnerabilities before they reach the cloud.

| Tool | Purpose | Key Check |
| :--- | :--- | :--- |
| **Checkov** | Compliance & Cloud best practices. | "Encrypted S3 bucket required." |
| **tfsec** | High-performance security scanning. | "Security group opens port 22 to the world." |
| **TFLint** | Syntax and provider-specific errors. | "Deprecated instance type usage." |
| **Gitleaks** | Secret detection in Git history. | "Detected AWS Access Key in commit." |

---

## 🏗️ 5. Real-Life Scenarios

### Scenario 1: The "Public State" Ransom
*   **The Problem**: A junior dev created an S3 bucket for state storage but forgot to enable "Block Public Access."
*   **The Incident**: A bot scanned for public buckets. It found the `terraform.tfstate` file, downloaded it, and extracted the RDS master password.
*   **The Consequence**: The hacker logged into the DB, encrypted the data, and demanded a ransom.
*   **The Fix**: Use **Organization-level SCPs** (Service Control Policies) that ban the creation of public S3 buckets across all accounts.

### Scenario 2: The Hardcoded "Default" Trap
*   **The Problem**: A developer included a password as a `default` value in a variable. They realized the mistake and deleted it in the next commit.
*   **The Incident**: An automated scanner found the secret in the **Git Commit History**.
*   **The Fix**: Delete the secret from the cloud (Rotate) immediately. Merely deleting it from the code is useless. Use **pre-commit hooks** to block commits containing high-entropy strings.

### Scenario 3: The "Admin-CI" Latency
*   **The Problem**: A Jenkins server used a static Access Key with `full_admin` permissions.
*   **The Incident**: The Jenkins UI was compromised. The attacker used the stored AWS key to provision massive crypto-mining GPU instances in an obscure region (us-west-1).
*   **The Fix**: Migrate to **OIDC (OpenID Connect)**. CI/CD runners only receive temporary, 1-hour credentials and do not store static keys.

---

## ❓ 6. Interview Questions (Expert Deep Dive)

1.  **Does `sensitive = true` encrypt data in the `.tfstate` file?**
    <details>
    <summary>Show Answer</summary>
    **No**. It only redacts the output in the CLI. The data is stored in plain text JSON within the state file. Security for this data must be provided by the backend storage (e.g., S3 Bucket Encryption and IAM policies).
    </details>

2.  **What is the "Supply Chain" risk in Terraform?**
    <details>
    <summary>Show Answer</summary>
    Using third-party modules from the public registry without pinning versions or auditing source code. A malicious actor could update a public module to include a `local-exec` provisioner that exfiltrates your credentials during `apply`.
    </details>

3.  **Explain the difference between "Sentinel" and "Checkov".**
    <details>
    <summary>Show Answer</summary>
    **Checkov** is an open-source static analysis tool that runs on the code *locally*. **Sentinel** is HashiCorp's proprietary Governance-as-Code engine that runs *inside* Terraform Cloud/Enterprise during the Plan phase, providing hard-enforcement guardrails that cannot be bypassed.
    </details>

4.  **Why is `local-exec` considered a major security risk?**
    <details>
    <summary>Show Answer</summary>
    It allows the execution of arbitrary shell commands on the runner. This logic is hidden from Terraform's plan and state, bypassing most automated security scanners and providing a gateway for malicious script execution.
    </details>

5.  **How do you secure a multi-account organization with Terraform?**
    <details>
    <summary>Show Answer</summary>
    Use a **Centralized Identity Account**. Developers authenticate to the Identity account and **Assume Role** into the Target accounts (Dev/Stage/Prod). This ensures no long-lived keys are needed in the target environments.
    </details>

---

## 🧠 7. Knowledge Check (Final Quiz)

### State & Encryption
1.  **State files stored in S3 are by default:**
    - [ ] Encrypted by HashiCorp.
    - [x] Unencrypted unless Server-Side Encryption (SSE) is enabled in the backend config.
2.  **The best way to protect a state file is:**
    - [x] S3 Encryption + Bucket Versioning + Strict IAM Policy.
    - [ ] Encrypting the `.tf` files with PGP.

### Secrets & IAM
3.  **Which is the most secure way to handle a DB password?**
    - [ ] Environment variable `TF_VAR_password`.
    - [x] Fetching from **HashiCorp Vault** or **AWS Secrets Manager** at runtime.
4.  **OIDC (OpenID Connect) provides:**
    - [x] Short-lived, keyless authentication for CI/CD runners.
    - [ ] Faster code execution.

### Policy & Compliance
5.  **A "Hard Mandatory" Sentinel policy:**
    - [ ] Warns the user but allows 'apply'.
    - [x] Blocks the code from being applied until it is compliant.
6.  **Drift Detection identifies:**
    - [x] Manual changes made via the Cloud Console (Shadow IT).
    - [ ] Code syntax errors.

---

## 📖 8. Summary Checklist

✅ **Encryption Always**: Enable `encrypt = true` in the backend.
✅ **State Versioning**: Enable S3 Bucket Versioning to recover from corruption.
✅ **Secret Separation**: Use Secrets Manager or Vault for all dynamic credentials.
✅ **Static Scanning**: Run `tfsec` or `checkov` in every Pull Request.
✅ **Machine Identity**: Use OIDC/IAM Roles for CI/CD; ban static Access Keys.

---
**Module Status**: ✅ Comprehensive Verified
**Last Updated**: 2026-01-08
