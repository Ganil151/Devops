# Module Best Practices

Writing Terraform is easy. Writing *maintainable*, *scalable*, and *secure* Terraform modules is an art. This guide applies software engineering principles to Infrastructure as Code.

## 1. SOLID Principles for Terraform

Software design principles apply directly to modules.

### Single Responsibility Principle (SRP)
**Concept**: A module should do one thing and do it well.
*   **Good**: `vpc-module` (Creates network), `rds-module` (Creates DB).
*   **Bad**: `app-infrastructure` (Creates VPC + EKS + RDS + Route53 all in one).
*   **Why**: "God Modules" are impossible to test, update, or reuse.

### Open/Closed Principle
**Concept**: Modules should be open for extension but closed for modification.
*   **Impl**: Allow users to pass in variable tags or optional configs without editing the `main.tf` code. Use `dynamic` blocks to allow variable lists of rules.

### Dependency Inversion
**Concept**: High-level modules should not depend on low-level implementation details.
*   **Impl**: Don't hardcode `subnet-12345`. Pass `var.subnet_ids` as a list.

---

## 2. Naming Standards

Consistency is the key to scalability.

### Resource Naming
*   **Pattern**: Use `this` or `main` for the primary resource in a simple module.
    *   `resource "aws_s3_bucket" "this" { ... }`
*   **Why**: If you refactor or rename the file, you don't have to rename all references like `aws_s3_bucket.my_weird_bucket_name.id`.

### Variable Naming
*   **Pattern**: `<component>_<feature>`
    *   `db_name`, `db_password`, `enable_logging`.
*   **Anti-Pattern**: Short, vague names like `n`, `p`, `log`.

### Output Naming
*   **Pattern**: Matching resource attributes where possible.
    *   `vpc_id`, `public_subnets`, `cluster_endpoint`.

---

## 3. Module Anatomy & Files

| File | Purpose | Rule |
| :--- | :--- | :--- |
| `main.tf` | Core logic | Keep it under 300 lines if possible. Split complex logic into `network.tf`, `storage.tf` if needed. |
| `variables.tf` | Inputs | **ALWAYS** include a `description` and `type`. |
| `outputs.tf` | Return values | **ALWAYS** include a `description`. |
| `README.md` | Documentation | Use `terraform-docs` to generate automatically. |
| `versions.tf` | Constraints | Pin `required_version` and providers. |
| `LICENSE` | Business | Essential for public modules. |

---

## 4. Security First

*   **Secrets**: NEVER hardcode secrets. Mark variables as `sensitive = true`.
    ```hcl
    variable "db_password" {
      type      = string
      sensitive = true
    }
    ```
*   **Checkov/TFLint**: Run static analysis in CI/CD before publishing.
*   **Least Privilege**: Don't give the module `admin` access. Pass specific IAM roles.

---

## 5. Visual Guide: The Clean Module Lifecycle

```mermaid
graph LR
    A[Design (SRP)] --> B[Develop (Standard Naming)]
    B --> C[Document (README/Examples)]
    C --> D[Test (TFLint/Terratest)]
    D --> E[Tag & Release (SemVer)]
    E --> F[Consume (Root Module)]
```

---

## 6. Real-Life Scenarios

### Scenario 1: The "Monolithic Module" Refactor
**Problem**: An organization had a `standard-app` module that deployed EC2, ALB, ASG, RDS, and ElastiCache. It was 2500 lines long.
**Consequence**: Updating the RDS version required destroying the ALB for some users due to tangled dependencies. Development froze.
**Solution**: Broke it down into `app-compute`, `app-db`, and `app-lb` modules. Composed them in the Root Module.

### Scenario 2: The "Hardcoded Creds" Disaster
**Problem**: A junior engineer hardcoded an AWS `access_key` in `providers.tf` inside a module to "test it quickly."
**Consequence**: The module was pushed to a private registry. The key was leaked to 50+ dev teams. Bots scraped it and mined crypto.
**Prevention**: **NEVER** put provider blocks with credentials inside a module. Always inherit from the caller.

### Scenario 3: "Naming Chaos"
**Problem**: Team A used `project-env-app`, Team B used `app-project-env`, Team C used `app_env`.
**Consequence**: Security audits and cost allocation became impossible because tags and names were inconsistent.
**Solution**: Created a `null_label` module that enforced a standard naming convention corporate-wide.

---

## 7. ❓ Interview Questions

1.  **Why should you avoid defining a `provider` block inside a child module?**
    *   **Answer**: It prevents the user from customizing the provider (region, aliases) and creates "Legacy Provider" issues that are hard to remove. Modules should inherit providers.

2.  **What is the purpose of `sensitive = true` in a variable?**
    *   **Answer**: It prevents the value from being displayed in cleartext in the CLI output (`terraform plan/apply`). *Note: It is still visible in the state file.*

3.  **Explain the "Single Responsibility Principle" for Terraform.**
    *   **Answer**: A module should own one logical component. If a module manages both "Networking" and "Application Logic," it violates SRP and should be split.

4.  **Why use `this` as a resource name inside a module?**
    *   **Answer**: It standardizes references (`aws_instance.this.id`) making code reusable and refactoring easier.

5.  **How do you handle "optional" resources in a module?**
    *   **Answer**: Use `count` (0 or 1) or `for_each` based on a boolean or list variable.

6.  **What tool would you use to automatically generate documentation?**
    *   **Answer**: `terraform-docs`.

7.  **Should you commit `.terraform.lock.hcl` for a module?**
    *   **Answer**: Generally No for *child modules* (libraries), but Yes for *root modules* (deployments). However, in modern Terraform, checking it in for modules can help consistency.

8.  **How do you enforce naming conventions?**
    *   **Answer**: Use validation rules in variables (`regex`), or use a standard "Label" module that generates names.

9.  **What is a "Composite Module"?**
    *   **Answer**: A module that calls other modules (e.g., a "Web Stack" module that calls "VPC" and "EC2" modules).

10. **Why limit the size of `main.tf`?**
    *   **Answer**: Readability and maintainability. Large files are hard to review and debug.

---

## 8. 🧠 Knowledge Check (Quiz)

### Core Principles
1.  **SRP stands for:**
    *   [ ] Simple Resource Provisioning
    *   [x] Single Responsibility Principle
    *   [ ] Secure Resource Policy

2.  **The "Open/Closed" principle means:**
    *   [x] Open for extension, closed for modification.
    *   [ ] Open source, closed source.
    *   [ ] Open ports, closed firewalls.

3.  **A "God Module":**
    *   [x] Tries to do everything and is hard to maintain.
    *   [ ] Is a super-admin module.

4.  **Modules should generally inherit:**
    *   [x] Providers
    *   [ ] Secrets
    *   [ ] State files

5.  **`terraform-docs` generates:**
    *   [ ] Code
    *   [x] Markdown documentation (Inputs/Outputs tables)
    *   [ ] Python scripts

### Structure & Naming
6.  **Best practice for naming the primary resource:**
    *   [ ] `main_resource_for_app`
    *   [x] `this` or `main`
    *   [ ] `primary`

7.  **Variable descriptions are:**
    *   [ ] Optional
    *   [x] Mandatory for good documentation

8.  **`sensitive = true` hides data from:**
    *   [ ] The State File
    *   [x] CLI Output
    *   [ ] The Provider

9.  **You should hardcode regions in modules:**
    *   [ ] Always
    *   [x] Never (Pass them or inherit)

10. **To make a list of rules dynamic:**
    *   [x] Use `dynamic` blocks.
    *   [ ] Use copy-paste.

### Scenarios
11. **If a module is too large:**
    *   [ ] Increase memory.
    *   [x] Refactor and split it.

12. **Inconsistent naming leads to:**
    *   [x] Security and billing audit failures.
    *   [ ] Faster deployments.

13. **Why use a "Label" module?**
    *   [ ] To add colors to CLI.
    *   [x] To enforce consistent naming standards across the org.

14. **If a user needs to change a hardcoded value:**
    *   [x] Expose it as a variable with a default.
    *   [ ] Tell them to fork the repo.

15. **Semantic Versioning `v1.0.0` means:**
    *   [ ] Alpha release.
    *   [x] Stable, production-ready.

### Advanced
16. **Dependency Inversion in Terraform means:**
    *   [x] Depending on abstractions (IDs/Lists) rather than concrete resource references.
    *   [ ] Dependencies are reversed.

17. **Can a module call another module?**
    *   [x] Yes (Composition).
    *   [ ] No.

18. **Where should `validation` blocks go?**
    *   [x] Inside the `variable` block.
    *   [ ] Inside logic.

19. **Drift detection is harder if:**
    *   [ ] You use modules.
    *   [x] You change resources manually in the console (ClickOps).

20. **Is `local-exec` a best practice?**
    *   [ ] Yes, use it everywhere.
    *   [x] No, use it as a last resort (breaks state/idempotency).
