# Terraform: Infrastructure as Code (IaC)

Terraform is an open-source tool that allows you to define both cloud and on-premise resources in human-readable configuration files that you can version, reuse, and share.

---

## 1. Declarative vs. Imperative

Terraform is **Declarative**. This means you describe the "desired state" of your infrastructure (e.g., "I want 3 servers with these tags"), and Terraform works out the "How" to make it happen.

### Why declarative?
- **Idempotency**: Running the same code multiple times results in the same outcome.
- **Traceability**: The code represents exactly what exists in your cloud environment.
- **Ease of Management**: You don't need to write complex logic to check if a resource already exists.

---

## 2. The Terraform Lifecycle

Every Terraform project follows a predictable workflow:

1.  **Init**: Initializes the working directory and downloads necessary provider plugins.
2.  **Plan**: Generates an execution plan, showing exactly what Terraform will create, change, or destroy.
3.  **Apply**: Executes the plan to reach the desired state.
4.  **Destroy**: Removes all resources managed by the project.

---

## 3. Directory Structure & Learning Path

### 🎓 [01. Fundamentals](./Fundamentals/)
The building blocks of HCL (HashiCorp Configuration Language).
- [Terraform Fundamentals Guide](./Fundamentals/terraform-fundamentals-guide.md)
- [Project Organization](./Infrastructure-as-Code/terraform-iac-guide.md)

### 📦 [02. Modules & Reusability](./Modules/)
Don't repeat yourself (DRY).
- [Module Development Guide](./Modules/terraform-modules-guide.md)

### 💾 [03. State Management](./State-Management/)
How Terraform tracks your infrastructure.
- [State Management & Backends](./State-Management/terraform-state-guide.md)

### 🚀 [04. Production Readiness](./Best-Practices/) & [Advanced Topics](./Advanced-Topics/)
Hardening your IaC for enterprise use.
- [Best Practices](./Best-Practices/terraform-best-practices-guide.md)
- [Enterprise Patterns](./Advanced-Topics/terraform-advanced-guide.md)

---

## ☁️ Terraform Cloud (HCP Terraform)

For teams working together, **Terraform Cloud** provides a centralized, collaborative environment:
- **Managed Backends**: Remote state management with locking.
- **VCS Integration**: Trigger runs via Pull Requests.
- **Policy Enforcement**: Sentinel and OPA.
- **Full Guide**: [Explore Terraform Cloud & Workflows](./Terraform-Cloud/)

---

## 4. State: The Single Source of Truth

Terraform uses a **State File** (`terraform.tfstate`) to map your real-world resources to your configuration.
- **Locking**: Prevents multiple people from changing infrastructure at the same time.
- **Remote Backends**: Use S3, GCS, or Azure Blob Storage to store state safely and collaborate with teams.

---

## 5. Security & Best Practices
1. **Never commit secrets**: Use environment variables or `tfvars` (which should be in `.gitignore`).
2. **Review your Plans**: Always read the `terraform plan` output carefully before applying.
3. **Use Version Constraints**: Pin your provider and module versions to avoid breaking changes.

---
**Practical Experience**: Explore the [AWS Projects](./Aws_Projects/) for real-world infrastructure templates.