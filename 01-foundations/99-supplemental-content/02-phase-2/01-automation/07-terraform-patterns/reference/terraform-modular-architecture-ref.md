# 🏗️ Terraform Modular Architecture
*Version 1.0 | Engineering DRY and Scalable Infrastructure Code*

---

## 🏛️ Executive Summary
Infrastructure modules are self-contained packages of Terraform configurations that manage a specific group of resources. They are the primary mechanism for implementing the **DRY (Don't Repeat Yourself)** principle and creating a standard service catalog for an organization.

---

## 🚀 The "DevOps Why"
Without modules, a 1,000-node environment would require thousands of lines of copy-pasted code. DevOps engineers use modules to abstract complexity (e.g., "The VPC Module") so that teams can provision a standard network with 5 lines of code instead of 500.

---

## 🏗️ Technical Pillars: Module Anatomy

### 1. Standard Module Structure
- `main.tf`: The actual resource definitions.
- `variables.tf`: The inputs (configuration).
- `outputs.tf`: The attributes exposed to the calling code (e.g., `vpc_id`).
- `README.md`: Documentation for users.

### 2. Module Sources
- **Local Paths**: `./modules/vpc` (Internal use).
- **Git**: `github.com/my-org/tf-vpc` (Cross-team sharing).
- **Terraform Registry**: High-quality community modules (e.g., `terraform-aws-modules/vpc`).

---

## ⚙️ Logic Standards: Abstraction vs. Granularity

| Pattern | Complexity | Reusability | SRE Rule |
| :--- | :--- | :--- | :--- |
| **Fat Module** | High | Low | **Avoid**. Too hard to change without breaking unrelated parts. |
| **Thin Module**| Low | High | **Prefer**. Single-purpose (e.g., "S3 Bucket" module). |
| **Wrapper** | Medium | High | **Best Practice**. Wrap community modules with Org-specific defaults. |

---

## 🚀 Advanced SRE Patterns

### 1. Composition
Passing the output of one module into the input of another.
```hcl
module "network" { source = "./vpc" }
module "app" {
  source = "./web_server"
  vpc_id = module.network.vpc_id # Data Flow
}
```

### 2. Module Versioning
Always use a **Version Pin** when calling remote modules to prevent "Breaking Changes" from crashing your next deployment.
`version = "2.3.0"`

---

## 🧪 Real-World Troubleshooting
**Scenario**: "I changed a variable in the module, but Terraform didn't update the resource."
- **Root Cause**: Check if the resource in `main.tf` actually uses the variable. Often, hardcoded strings are left behind during the transition to modules.
- **Solution**: Ensure all configurable attributes are mapped to `var.variable_name`.

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain the difference between a "Module" and a "Provider".**
2. **What is the `count` vs `for_each` trade-off when creating multiple resources inside a module?**
3. **Describe how "Sensitivity" flags (`sensitive = true`) behave in module outputs.**
4. **How do you handle "Circular Dependencies" between two modules?**
5. **Describe the impact of the `terraform get` command.**

---
**Next Step**: [Security, Sentinel & Compliance →](./terraform-security-compliance-ref.md)
