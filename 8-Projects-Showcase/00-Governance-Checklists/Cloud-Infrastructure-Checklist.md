# ☁️ Cloud Infrastructure: Definition of Done Checklist

> **"Infrastructure as Code is not about 'writing scripts'; it's about treating your data center like a software product."**

---

## 1. Provisioning & State Management

- [ ] **Idempotent IaC Implementation**
    - **The "Why"**: Ensures that running the provisioning command multiple times produces the same result without side effects or errors.
    - **Verification**: Run `terraform apply` twice. The second run should indicate "0 to add, 0 to change, 0 to destroy."
    - **Command**: `terraform plan` or `bicep build`.

- [ ] **Remote State Locking**
    - **The "Why"**: Prevents state corruption during concurrent access by multiple team members or CI/CD runners.
    - **Verification**: Verify that a remote backend (S3+DynamoDB, Azure Storage, Terraform Cloud) is configured with locking enabled.
    - **Command**: `terraform providers` and check `backend.tf`.

---

## 2. Resource Governance & Metadata

- [ ] **Mandatory Tagging Strategy**
    - **The "Why"**: Enables granular cost tracking, resource ownership identification, and automated patching logic.
    - **Verification**: Check cloud resources for a minimum set of tags: `Environment`, `Project`, `Owner`, `CostCenter`.
    - **Command**: `aws resourcegroupstaggingapi get-resources` or `az resource list --query "[].tags"`.

- [ ] **Least-Privilege Security Groups/NSGs**
    - **The "Why"**: Minimizes the blast radius of a potential breach by only allowing necessary traffic on specific ports.
    - **Verification**: Verify that no security group has `0.0.0.0/0` (Any) access for management ports (SSH/RDP).
    - **Command**: `aws ec2 describe-security-groups --query "SecurityGroups[*].IpPermissions"` or `az network nsg rule list`.

---

## 3. Financial & Operational Readiness

- [ ] **Cost Estimation (Pre-deployment)**
    - **The "Why"**: Prevents "Sticker Shock" by identifying expensive resource choices before they are provisioned.
    - **Verification**: Check the project documentation for an automated or manual cost estimate.
    - **Command**: `infracost breakdown --path .` if integrated into CI.

- [ ] **Automated Deletion/Expiration (for Dev/Test)**
    - **The "Why"**: Reduces unnecessary cloud spending by automatically cleaning up ephemeral environments.
    - **Verification**: Verify that a 'TTL' tag or an automated cleanup script is active.
    - **Command**: `aws ec2 describe-instances --filters "Name=tag:Cleanup,Values=True"`.

---

## ❓ Professional Validation (Interview Readiness)

1. **Q: Why do we use 'Variables' instead of hardcoding values in Terraform?**
   - *A: To make the code reusable across environments (Dev/Test/Prod) and to keep sensitive data like account IDs out of the source code.*

2. **Q: What is the risk of manual changes ("Click-Ops") in a cloud environment?**
   - *A: It leads to 'Configuration Drift,' making it impossible to reproduce the environment exactly and potentially causing hidden security vulnerabilities.*
