# Security Best Practices

Infrastructure as Code (IaC) is a double-edged sword. It allows you to build secure infrastructure at scale, but a single mistake can expose your entire organization.

## 1. Protecting the State File

The `.tfstate` file is the "Keys to the Kingdom." It contains **unencrypted** resource data, including database passwords and private keys (even if marked `sensitive`).

### Encryption at Rest
*   **S3 Backend**: Always enable Server-Side Encryption (SSE).
    ```hcl
    backend "s3" {
      bucket = "my-state"
      key    = "prod/terraform.tfstate"
      region = "us-east-1"
      encrypt = true  # Crucial
      kms_key_id = "arn:aws:kms:..."
    }
    ```

### Access Control
*   **Principle**: Only CI/CD pipelines and Break-glass admins should have read/write access to the State Bucket. Developers should generally use `terraform plan` (read-only state) or remote execution.

---

## 2. Secrets Management

**Rule #0**: NEVER commit secrets to Git.

### The "Sensitive" Flag
Label variables and outputs as sensitive to redact them from CLI logs.
```hcl
variable "db_password" {
  type      = string
  sensitive = true
}

output "db_password" {
  value     = aws_db_instance.this.password
  sensitive = true
}
```
*Note: This does NOT encrypt them in the state file. It only hides them from human eyes in the logs.*

### Injecting Secrets Patterns

1.  **Environment Variables**: Good for simple secrets.
    *   `export TF_VAR_db_password="supersecret"`
2.  **AWS Systems Manager (SSM) / Secrets Manager** (Recommended):
    *   Store the secret in AWS.
    *   Terraform reads it as a `data` source.
    ```hcl
    data "aws_secretsmanager_secret_version" "db_creds" {
      secret_id = "prod/db/password"
    }
    
    resource "aws_db_instance" "this" {
      password = data.aws_secretsmanager_secret_version.db_creds.secret_string
    }
    ```

### Visual: Secure Secret Flow

```mermaid
graph LR
    Dev[Developer] -->|Creates| AWS[AWS Secrets Manager]
    TF[Terraform Code] -->|Reference| Data[Data Source]
    Data -.->|Fetch at Runtime| AWS
    Data -->|Inject| Res[Resource (DB)]
    
    style Dev fill:#f9f,stroke:#333
    style AWS fill:#ff9,stroke:#333
    style TF fill:#9f9,stroke:#333
```

---

## 3. Least Privilege (IAM)

Don't run Terraform with `AdministratorAccess`.

*   **Role Assumption**: Configure your provider to assume a specific role for deployment.
    ```hcl
    provider "aws" {
      assume_role {
        role_arn = "arn:aws:iam::123456789:role/TerraformDeployRole"
      }
    }
    ```
*   **Scoped Policies**: If a stack only deploys S3 buckets, the `TerraformDeployRole` should only have `s3:*` permissions, not `ec2:*`.

---

## 4. Static Analysis (Shift Left)

Catch security issues *before* deployment using tools.

*   **Checkov**: Scans for compliance (e.g., "S3 bucket not encrypted").
*   **tfsec**: Detailed security scanning for Terraform code.
*   **TFLint**: Finds deprecated syntax and logic errors.

**Example Checkov Failure:**
> `FAILED for resource: aws_s3_bucket.foo`
> `Check: Ensure all S3 buckets have public access blocks`

---

## 5. Real-Life Scenarios

### Scenario 1: "The Public State File"
**Problem**: A junior engineer created an S3 bucket for state storage but didn't check "Block Public Access".
**Event**: A security researcher scanned for public buckets named `terraform` or `state`. They downloaded the state file, extracted the RDS root password, and accessed the database.
**Fix**: Enforce "Block Public Access" on all S3 buckets via SCP (Service Control Policy) and enable Encryption.

### Scenario 2: "The Hardcoded Password"
**Problem**: A developer hardcoded a password in `variables.tf` default value.
**Event**: They realized the mistake and deleted it in the next commit.
**Consequence**: Git history is forever. A hacker cloned the repo, ran `git log -p`, and found the removed password.
**Fix**: Rotate credentials immediately. Rewrite Git history (BFG Repo-Cleaner) or delete the repo. Use pre-commit hooks to detect secrets.

### Scenario 3: "Super-Admin CI/CD"
**Problem**: The Jenkins server used an AWS Access Key with `AdministratorAccess` to run Terraform.
**Event**: The Jenkins dashboard was exposed to the internet with a weak password. Attackers used the jenkins shell to run scripts that mined crypto using the Admin keys.
**Fix**: Use OIDC (OpenID Connect) for CI/CD authenticating to AWS (no long-lived keys) and scope permissions to "Least Privilege".

---

## 6. ❓ Interview Questions

1.  **Does `sensitive = true` encrypt data in the `.tfstate` file?**
    *   **Answer**: No. It only redacts the output in the CLI. The data is stored in plain text (usually JSON) in the state file. This is why encrypting the state bucket is mandatory.

2.  **What is the safest way to pass a database password to Terraform?**
    *   **Answer**: Using a dynamic lookup (Data Source) from a secrets store like AWS Secrets Manager or Vault. Alternatively, passing it as an environment variable (`TF_VAR_password`) in a secure CI/CD environment.

3.  **Why should you avoid using the `admin` IAM user's access keys for Terraform?**
    *   **Answer**: It violates Least Privilege. If the keys are leaked or the machine is compromised, the attacker has full control. Use Role Assumption with scoped permissions.

4.  **What tool would you use to scan Terraform code for security vulnerabilities *before* apply?**
    *   **Answer**: Static Application Security Testing (SAST) tools like **Checkov**, **tfsec**, or **Terrascan**.

5.  **How do you handle "Drift" where someone manually changes a Security Group rule?**
    *   **Answer**: Run `terraform plan`. It will detect the difference. To revert the manual change, run `terraform apply`. To keep it, import the change or update the code to match.

6.  **What is "Sentinel" (or OPA) in the context of Terraform?**
    *   **Answer**: Policy as Code. It allows you to define rules (e.g., "No S3 buckets allowed without encryption") that run during the Plan phase and block the release if violated.

7.  **Why is `local-exec` considered a security risk?**
    *   **Answer**: It executes arbitrary shell commands on the machine running Terraform. This logic is opaque to Terraform's state and can be used to exfiltrate credentials or install malware if the module source is untrusted.

8.  **If you delete a `sensitive` variable from code, is it removed from state?**
    *   **Answer**: Yes, upon the next `apply`, if the resource using it is updated/destroyed. However, historical state files (versioning) might still contain it.

9.  **What is the difference between `private` and `public` modules regarding security?**
    *   **Answer**: Private modules reside in your internal VCS or Registry and are trusted. Public modules come from the internet; you must audit them (or pin hashes) to ensure no malicious code was added (Supply Chain Attack).

10. **Explain how "OIDC" improves Terraform security in CI/CD.**
    *   **Answer**: OpenID Connect allows GitHub Actions/GitLab CI to authenticate to AWS using a temporary token signed by the provider, eliminating the need to store long-lived AWS Access Keys in CI/CD variables.

---

## 7. 🧠 Knowledge Check (Quiz)

### State & Secrets
1.  **State files stored in S3 are by default:**
    *   [ ] Encrypted.
    *   [x] Unencrypted (unless configured).

2.  **`sensitive = true` prevents:**
    *   [x] CLI output display.
    *   [ ] State file storage.

3.  **Which is the Best Practice for DB passwords?**
    *   [ ] `default = "password"`
    *   [ ] `terraform.tfvars` committed to Git.
    *   [x] AWS Secrets Manager lookup.

4.  **Before committing code, you should run:**
    *   [ ] `terraform apply`
    *   [x] `checkov` / `pre-commit` hooks.

5.  **If a secret is committed to Git:**
    *   [ ] Just delete the file.
    *   [x] Rotate the secret immediately and scrub history.

### IAM & Policies
6.  **Least Privilege means:**
    *   [ ] Giving everyone Admin.
    *   [x] Giving only the permissions necessary for the task.

7.  **Assume Role is better than Access Keys because:**
    *   [x] Credentials are temporary and rotate automatically.
    *   [ ] It's faster.

8.  **Service Control Policies (SCPs) are used to:**
    *   [x] Set guardrails on an Organization level (e.g., "Ban all public S3").
    *   [ ] Configure modules.

9.  **OPA stands for:**
    *   [ ] Open Process Automation.
    *   [x] Open Policy Agent.

10. **CI/CD pipelines should generally run as:**
    *   [ ] A human user.
    *   [x] A Machine user / Role.

### General
11. **Why enable S3 Versioning on the State Bucket?**
    *   [x] To recover from accidental state corruption or deletion.
    *   [ ] To save money.

12. **Locking (DynamoDB) prevents:**
    *   [x] Two concurrent applies corrupting state.
    *   [ ] Hackers reading state.

13. **Public modules should be:**
    *   [x] Audited and pinned by version.
    *   [ ] Blindly trusted.

14. **Is `0.0.0.0/0` acceptable in Security Groups?**
    *   [ ] Yes, always.
    *   [x] Only for public web (HTTP/HTTPS), never for SSH/RDP/DB.

15. **To ensure resources are encrypted, you can use:**
    *   [x] `checkov` rules.
    *   [ ] `terraform fmt`.

16. **Why use TLS/SSL for backend communication?**
    *   [x] To encrypt state data in transit.
    *   [ ] For faster speed.

17. **Can Terraform manage IAM Users?**
    *   [ ] No.
    *   [x] Yes (`aws_iam_user`), but prefer Roles/Federation for humans.

18. **The `.terraform` directory contains:**
    *   [x] Downloaded providers and modules (usually ignored in Git).
    *   [ ] Your secrets.

19. **Drift Detection helps identify:**
    *   [x] Security breaches or "Shadow IT" (manual changes).
    *   [ ] Code errors.

20. **Is hardcoding the Region a security risk?**
    *   [ ] Yes.
    *   [x] No, but it's bad for flexibility. (Hardcoding *Availability Zones* can be risky for HA).
