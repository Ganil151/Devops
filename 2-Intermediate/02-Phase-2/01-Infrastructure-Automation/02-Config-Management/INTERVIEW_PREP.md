# 🎙️ Infrastructure as Code Master Interview Prep

This document contains "Staff/Senior Level" questions designed to test deep architectural knowledge of IaC and Configuration Management.

---

### 1. How do you manage cross-module dependencies in Terraform without creating circular references?
**Answer**: Best practice is to use a "Dependency Injection" pattern via **Data Sources** or **Inputs/Outputs**. If Module A needs a VPC ID from Module B, Module B should output that ID, and the root module should pass it into Module A as a variable. For loosely coupled systems, use `terraform_remote_state` data sources to fetch information directly from the state of another project.

### 2. Explain the "Thundering Herd" problem in Terraform and how to mitigate it.
**Answer**: This occurs when a large automation suite (like a CI pipeline) triggers hundreds of `terraform plan/apply` commands simultaneously against the same API (e.g., AWS). It can lead to Rate Limiting (Throttling). Mitigation includes:
- Implementing Randomized Jitter in pipeline triggers.
- Using `parallelism=N` flag to limit concurrent operations.
- Breaking large monorepos into smaller, independent state files.

### 3. What is the difference between "Mutable" and "Immutable" infrastructure, and when would you choose one over the other?
**Answer**: 
- **Mutable (Ansible/Chef)**: You change the server in place (patching, config updates). Better for long-running legacy apps or large DBs.
- **Immutable (Packer/Terraform)**: You never change a server. You build a new image, deploy it, and destroy the old one. Better for stateless microservices to ensure consistency and zero-drift.

### 4. How do you handle secrets (DB passwords, API keys) in Terraform code?
**Answer**: **Never** store them in plain text.
- Use environment variables (`TF_VAR_`).
- Use a Secret Manager (AWS Secrets Manager, HashiCorp Vault).
- Use `sensitive = true` in variable definitions to redact them from CLI output.
- **Note**: Remember that secrets are still stored in plain text in the `.tfstate` file, so the state file must be encrypted at rest and access-controlled.

### 5. What happens if `terraform apply` is interrupted (e.g., network failure)?
**Answer**: The state can become "tainted" or partially updated. Terraform might have created a resource but didn't get a chance to record it in the state file.
- **Action**: Run `terraform plan` to see the drift. If a resource exists in the cloud but not in the state, use `terraform import` to regain control.

### 6. In Ansible, what is the 'Idempotency' principle?
**Answer**: A module is idempotent if running it multiple times has the same effect as running it once. For example, the `apt` module will only install a package if it's not already present. This ensures that re-running playbooks doesn't break a healthy system.

### 7. Describe the "Three-Tiered" approach to Terraform repository structure.
**Answer**: 
1. **Global/Foundation**: IAM, VPC, DNS (Changes slowly).
2. **Platform**: Managed Kubernetes, Databases, Logging (Changes moderately).
3. **Application**: Specific app resources, S3 buckets, SQS (Changes frequently).
Each tier has its own state file to limit the "Blast Radius" of a failure.

### 8. How do you implement Zero-Downtime deployments with Blue/Green at the IaC level?
**Answer**: 
1. Provision the "Green" environment (new version) using a new Terraform workspace or set of variables.
2. Verify Green is healthy.
3. Update the Load Balancer (or Route 53) target group to point from Blue to Green.
4. Once traffic is shifted, destroy the Blue environment via Terraform.

### 9. What is the benefit of `Helmfile` over raw `Helm` charts?
**Answer**: `Helmfile` allows you to manage multiple Helm releases in a single declarative file. It handles environment-specific values more cleanly and can define dependencies between different charts (e.g., "Don't deploy the app until the DB chart is ready").

### 10. How do you detect and fix "Configuration Drift"?
**Answer**:
- **Detect**: Run periodic `terraform plan` or `ansible --check` via a cron job or GitOps tool like Atlantis or ArgoCD.
- **Fix**: Re-apply the code to bring the environment back to the desired state. If the drift was intentional (emergency fix), update the code to match the manual change.
