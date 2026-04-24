# ❓ Technical Interview: Config Management & IaC

> **"The difference between a Junior and a Staff Engineer is not what they know, but how they think when things break at 3 AM."**

These questions are designed to test **architectural thinking**, **production experience**, and **decision-making under pressure**. They reflect real scenarios from senior-level interviews at companies like AWS, HashiCorp, and Netflix.

---

## 🏗️ Foundational Concepts

### 1. Explain 'Infrastructure as Code' vs 'Infrastructure as a Service'.
**Answer**: IaaS is the "What" (the cloud providing you a VM). IaC is the "How" (the code files you write to tell that cloud to give you the VM). IaC brings software engineering practices (Git, CI, testing) to hardware management.

**Follow-up**: *"How would you implement IaC for a hybrid cloud environment spanning AWS and on-premises VMware?"*

### 2. What is 'Configuration Drift' and how do you prevent it?
**Answer**: Drift occurs when the actual system state deviates from the code state. You prevent it by:
- Using **Idempotent** tools (Terraform/Ansible).
- Running **Periodic Checks** (Terraform Plan on a schedule).
- Implementing **GitOps** (automated reconciliation).
- Disabling manual access to the cloud console (enforce IAM policies).
- Using **Cloud Custodian** or **AWS Config** for compliance monitoring.

**Production Story**: *"At a fintech company, an engineer manually changed a security group to 'temporarily' allow SSH from 0.0.0.0/0. The drift wasn't detected for 3 weeks until a security audit. The fix: Scheduled `terraform plan` runs in CI with Slack alerts on any drift."*

### 3. Difference between 'Immutable' and 'Mutable' infrastructure?
**Answer**: 
- **Mutable**: You patch existing servers (e.g., using Ansible to update a library).
- **Immutable**: You build a new image (Packer) and replace the server (Terraform). 

In modern Cloud-Native environments, Immutable is preferred for predictability and scaling speed.

**Staff Nuance**: *"Immutable is ideal for stateless apps (web servers, containers). Mutable is necessary for stateful systems (databases, Kafka brokers) where data locality matters."*

---

## 🔐 State Management & Security

### 4. What is 'State' in IaC, and why is it dangerous?
**Answer**: State is the "Map" between your code and the real world. It's dangerous because:
- If **lost**, the tool doesn't know what it owns (orphaned resources).
- If **leaked**, it may contain secrets (database passwords, API keys).
- If **corrupted**, you risk destroying production infrastructure.

**Mitigation**:
- Store in **Remote Backend** (S3 + DynamoDB locking).
- Enable **Versioning** (S3 versioning for rollback).
- Enable **Encryption** (S3 SSE-KMS).
- Restrict access via **IAM policies** (least privilege).

### 5. How do you handle concurrent Terraform runs?
**Answer**: Use **State Locking** with a DynamoDB table:
```hcl
terraform {
  backend "s3" {
    bucket         = "company-tfstate"
    key            = "prod/app.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

**Production Scenario**: *"Two engineers run `terraform apply` simultaneously. Without locking, both read the same state, make different changes, and the last one to finish overwrites the first. With DynamoDB locking, the second engineer gets an error: 'Lock ID: abc123, held by alice@company.com'."*

### 6. How do you manage secrets in Terraform?
**Answer**: **Never hardcode secrets**. Use:
1. **Sensitive Variables**: Mark variables as `sensitive = true`.
2. **Environment Variables**: `TF_VAR_db_password`.
3. **Data Sources**: Fetch from AWS Secrets Manager or HashiCorp Vault.
4. **External Providers**: Use the `vault` provider to inject secrets at runtime.

**Anti-Pattern**: Storing secrets in `terraform.tfvars` and committing to Git.

---

## 🎭 Ansible & Configuration Management

### 7. What is 'Idempotency' in Ansible and why does it matter?
**Answer**: Idempotency means running a playbook 100 times produces the same result as running it once. This is critical for:
- **Safety**: You can re-run playbooks without fear of breaking things.
- **Drift Correction**: Automatically fix manual changes.
- **CI/CD Integration**: Playbooks can run on every commit.

**Example**:
```yaml
# Idempotent: Only installs if not present
- name: Ensure Nginx is installed
  apt: name=nginx state=present

# NOT Idempotent: Runs every time
- command: curl https://install.sh | bash
```

### 8. Ansible vs Terraform: When to use which?
**Answer**:
| Use Case | Tool | Why |
|:---------|:-----|:----|
| Create VPC, Subnets, EC2 | **Terraform** | Provisioning infrastructure. |
| Install Nginx, configure firewall | **Ansible** | Configuring OS and apps. |
| Deploy Docker containers | **Terraform** (ECS) or **Ansible** | Depends on orchestration layer. |
| Patch 500 servers | **Ansible** | SSH-based fleet management. |

**Staff Pattern**: Use **both** in a pipeline:
1. Terraform provisions the EC2 instances.
2. Terraform outputs the IPs to a dynamic inventory.
3. Ansible configures the instances using that inventory.

### 9. How do you handle OS-specific logic in Ansible?
**Answer**: Use **Facts** and **Conditionals**:
```yaml
- name: Install web server
  package:
    name: "{{ 'httpd' if ansible_os_family == 'RedHat' else 'apache2' }}"
    state: present
```

**Production Pattern**: Create separate role files:
- `tasks/main.yml` (common logic)
- `tasks/RedHat.yml` (RHEL-specific)
- `tasks/Debian.yml` (Ubuntu-specific)

Then include dynamically:
```yaml
- include_tasks: "{{ ansible_os_family }}.yml"
```

---

## 🚀 Advanced Scenarios

### 10. How do you implement Blue-Green deployments with Terraform?
**Answer**: Use **workspaces** or **separate state files**:
1. Deploy "Green" environment (new version) alongside "Blue" (current).
2. Update Load Balancer to point to Green.
3. Monitor for errors.
4. If successful, destroy Blue. If failed, rollback to Blue.

**Code Pattern**:
```hcl
resource "aws_lb_target_group" "blue" {
  name = "app-blue"
  # ... config
}

resource "aws_lb_target_group" "green" {
  name = "app-green"
  # ... config
}

resource "aws_lb_listener_rule" "main" {
  # Switch between blue and green
  target_group_arn = var.active_env == "green" ? 
    aws_lb_target_group.green.arn : 
    aws_lb_target_group.blue.arn
}
```

### 11. How do you test Terraform modules before production?
**Answer**: Use **Terratest** (Go-based testing framework):
```go
func TestVPCModule(t *testing.T) {
  terraformOptions := &terraform.Options{
    TerraformDir: "../modules/vpc",
    Vars: map[string]interface{}{
      "cidr_block": "10.0.0.0/16",
    },
  }
  
  defer terraform.Destroy(t, terraformOptions)
  terraform.InitAndApply(t, terraformOptions)
  
  vpcId := terraform.Output(t, terraformOptions, "vpc_id")
  assert.NotEmpty(t, vpcId)
}
```

**Alternative**: Use `terraform plan` in CI with `-detailed-exitcode` to fail on unexpected changes.

### 12. Describe a production incident you've resolved using IaC.
**Expected Answer Structure**:
1. **The Incident**: "Database connection pool exhausted due to misconfigured `max_connections`."
2. **The Investigation**: "Checked Terraform state, found hardcoded value of 100 instead of calculated value based on instance size."
3. **The Fix**: "Updated module to use `locals` with formula: `max_connections = instance_memory_gb * 25`."
4. **The Prevention**: "Added validation block to ensure value is within RDS limits."

---

## 🏆 Helm & Kubernetes Config

### 13. When would you use Helm over Kustomize?
**Answer**: 
- **Helm**: When you're building a **generic package** to be shared by many people or projects (e.g., "Install a database cluster"). Supports templating, versioning, and rollback.
- **Kustomize**: For **environment-specific overlays** where you just need to tweak a few settings (like environment variables) between Dev and Prod without the complexity of templates.

**Staff Recommendation**: Use **Helm for third-party apps** (Prometheus, Grafana). Use **Kustomize for your own apps**.

### 14. How do you manage Helm chart versions across environments?
**Answer**: Use **ArgoCD** or **Flux** with GitOps:
```yaml
# environments/dev/values.yaml
image:
  tag: "1.2.3-dev"
replicas: 1

# environments/prod/values.yaml
image:
  tag: "1.2.3"
replicas: 3
```

**Anti-Pattern**: Manually running `helm upgrade` from your laptop.

---

## 🎯 Behavioral & Decision-Making

### 15. You discover that production infrastructure was manually modified. What do you do?
**Answer**:
1. **Immediate**: Document the change (screenshot, AWS CloudTrail logs).
2. **Short-term**: Run `terraform plan` to see the drift. Decide if you need to `terraform apply` to revert or `terraform import` to accept the change.
3. **Long-term**: 
   - Implement **SCPs** (Service Control Policies) to prevent manual changes.
   - Enable **AWS Config Rules** to alert on drift.
   - Enforce **GitOps**: All changes must go through PR + CI/CD.

### 16. How do you balance speed vs. safety in infrastructure changes?
**Answer**: Use **Progressive Delivery**:
- **Dev**: Auto-apply on every commit.
- **Staging**: Auto-apply with smoke tests.
- **Production**: Require manual approval after `terraform plan` review.

**Tooling**: Use **Terraform Cloud** with policy-as-code (Sentinel/OPA) to enforce guardrails.

---

## 📝 Quick-Fire Round

1. **What does `terraform refresh` do?** 
   - Updates the state file to match reality without making changes.

2. **How do you rename a resource without destroying it?**
   - Use `terraform state mv`.

3. **What's the difference between `count` and `for_each`?**
   - `count` uses index (0, 1, 2). `for_each` uses keys (safer for refactoring).

4. **How do you prevent accidental deletion of a database?**
   - Use `lifecycle { prevent_destroy = true }`.

5. **What's the purpose of `ansible-vault`?**
   - Encrypt sensitive variables (passwords, API keys) in playbooks.

---

[⬅️ Back to Assessments](./readme.md)
