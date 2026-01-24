# 🏗️ Terraform Module Gallery

This directory serves as the centralized "Infrastructure-as-Code" (IaC) repository. Instead of writing raw Terraform for every project, use these pre-audited, modular components.

---

## 🗺️ Module Index

| Module Name | Tier | Primary Resources | Description |
| :--- | :--- | :--- | :--- |
| [VPC](./vpc/) | ⚙️ Network | VPC, Subnets, IGW, Routing | Enterprise multi-AZ VPC foundation. |
| [EC2](./ec2/) | ⚙️ Compute | Instances, KeyPairs, AMIs | Standardized Linux/Windows compute nodes. |
| [Security Groups](./security_group/) | 🛡️ Security | SG Rules, Inbound/Outbound | Identity-based firewall rules. |
| [S3](./s3/) | 💾 Storage | Buckets, Versioning, Encryption | Secure object storage with lifecycle policies. |

---

## 🏛️ The Core Concept
Terraform modules allow you to **package infrastructure**. A project should ideally call these modules and provide specific variables, rather than defining low-level resources like `aws_instance` directly.

## 🚀 The "Why" for DevOps
- **Reusability**: Write the VPC logic once; use it for Dev, Staging, and Prod.
- **Consistency**: Ensures every project has the same tagging and security defaults.
- **Governance**: Integrated with [Policy-as-Code](../01-Scripts-Code/Terraform/POLICY_AS_CODE_DEEP_DIVE.md) to audit plans before deployment.

### 📈 Visual Marker: Infrastructure Lifecycle
<div align="center">
  <img src="https://img.shields.io/badge/Strategy-Plan%20&%20Provision-blue?style=for-the-badge&logo=terraform" alt="Terraform Strategy Tag">
</div>

---

## ❓ Top 5 Interview Questions
1. **Q: What is a "Terraform Module"?**
   - *Answer*: A container for multiple resources that are used together. Every Terraform configuration has at least one module, known as its root module.
2. **Q: Explain the difference between `count` and `for_each`.**
   - *Answer*: `count` uses an index (0, 1, 2); `for_each` uses a map or set of strings. `for_each` is generally safer for managing resource identities if items are added or removed.
3. **Q: What is "State Locking"?**
   - *Answer*: A mechanism to prevent two team members from running Terraform at the same time and corrupting the state file (usually implemented via DynamoDB).
4. **Q: How do you handle sensitive outputs in a module?**
   - *Answer*: Use the `sensitive = true` attribute in the `output` block to prevent the value from being printed to the console.
5. **Q: What is the `lifecycle` block used for?**
   - *Answer*: To control Terraform's behavior for a specific resource (e.g., `prevent_destroy = true` or `create_before_destroy = true`).

---

## 🔗 Learning Links
- [Policy-as-Code Deep-Dive](../01-Scripts-Code/Terraform/POLICY_AS_CODE_DEEP_DIVE.md)
- [Multi-Cloud Landing Zone Roadmap](../../CAREER_ROADMAP.md)
