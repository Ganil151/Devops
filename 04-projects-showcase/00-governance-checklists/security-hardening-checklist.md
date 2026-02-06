# 🔐 Security Hardening: Definition of Done Checklist

> **"Security is not a layer; it's a foundation. If it's not verified, it's just a wish."**

---

## 1. Identity & Secret Management

- [ ] **No Hardcoded Secrets (Zero Leak Policy)**
    - **The "Why"**: Prevents credential theft by ensuring API keys, passwords, and tokens never exist in cleartext within source code or version history.
    - **Verification**: Run a secret scanning tool against the repository history.
    - **Command**: `gitleaks detect -v` or `trufflehog git file:///path/to/repo`.

- [ ] **Utilization of a Managed Secret Store**
    - **The "Why"**: Centralizes secret control, enables automated rotation, and provides audit logs of secret access.
    - **Verification**: Code should reference environment variables or a specific SDK call (e.g., Vault, AWS Secrets Manager).
    - **Command**: Check application code for calls to `boto3.client('secretsmanager')` or similar.

---

## 2. Infrastructure & Access Hardening

- [ ] **Implementation of "Least Privilege" IAM Roles**
    - **The "Why"**: Ensures that a compromised service or user has the minimum possible access, limiting the potential damage.
    - **Verification**: Review IAM policies for occurrences of `Action: "*"` or `Resource: "*"`. Replace with specific ARNs/Actions.
    - **Command**: `aws iam simulate-principal-policy` or review the policy JSON.

- [ ] **Encrypted Storage (Data-at-Rest)**
    - **The "Why"**: Protects data even if the underlying physical storage media is compromised or improperly disposed.
    - **Verification**: Verify that S3 buckets, EBS volumes, and RDS instances have encryption enabled (KMS).
    - **Command**: `aws ec2 describe-volumes --query "Volumes[*].Encrypted"`.

---

## 3. Continuous Security Validation

- [ ] **Vulnerability Scanning for Dependencies (SCA)**
    - **The "Why"**: Identifies insecure third-party libraries that could be used as an entry point for an attack.
    - **Verification**: Check for a vulnerability report in the CI pipeline or local development environment.
    - **Command**: `npm audit` (Node.js), `pip-audit` (Python), or `snyk test`.

- [ ] **Container Image Scanning**
    - **The "Why"**: Detects vulnerabilities within the OS packages and binaries packaged inside your Docker images.
    - **Verification**: Review scanning results; the build must fail if vulnerabilities above a specific threshold (e.g., High) are found.
    - **Command**: `trivy image <image_name>` or `docker scan <image_name>`.

---

## ❓ Professional Validation (Interview Readiness)

1. **Q: What is a "Secret Scanning" tool, and when should it run?**
   - *A: It's a tool that looks for high-entropy strings (keys/passwords). It should run as a pre-commit hook (locally) and as a mandatory gate in the CI pipeline.*

2. **Q: Explain "Defense in Depth" in the context of a web application.**
   - *A: It's using multiple layers of security (e.g., WAF, Security Group, IAM Role, and Application-level Auth). If one layer fails, others still protect the asset.*
