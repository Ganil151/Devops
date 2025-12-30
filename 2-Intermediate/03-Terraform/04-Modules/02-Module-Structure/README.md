# Module Structure

A well-structured module is easy to read, maintain, and share.

## Standard Module Layout
While Terraform doesn't enforce a specific structure, the industry standard (followed by the Terraform Registry) is:

```text
module-name/
├── main.tf        # Primary resource definitions
├── variables.tf   # Input definitions (The "Arguments")
├── outputs.tf     # Return values (The "Attributes")
├── providers.tf   # Required provider blocks
├── versions.tf    # Terraform & Provider version constraints
├── README.md      # Human-readable documentation
└── examples/      # Sub-directory with usage examples
```

## Role of Files
- **main.tf**: The "Meat" of the module. Contains the actual resources.
- **variables.tf**: Defines what the user *must* or *can* provide. Use `default` values sparingly for required items.
- **outputs.tf**: Defines what information the module "exports" back to the caller (e.g., a VPC ID or a Load Balancer DNS).
- **README.md**: Should describe the module's purpose, inputs, and outputs.

---

## 🏗️ Real-Life Scenario: The "Mystery Box" Module
**Problem**: A developer joins a team and sees a module called `app-infra`. It only has a `main.tf` with 2,000 lines of code. There are no comments and no `variables.tf`.
**Outcome**: The developer is afraid to change anything because they don't know what values are required.
**Solution**: Break the file down. Move inputs to `variables.tf` with descriptive `description` fields. Create a `README.md` using `terraform-docs`. Now, a new hire can understand the module in 5 minutes.

---

## ❓ Interview Questions
1.  **What are the three most important files in a Terraform module?**
    *   *Answer*: `main.tf`, `variables.tf`, and `outputs.tf`.
2.  **Why is it important to include a `versions.tf` file in a shared module?**
    *   *Answer*: It prevents the module from being used with incompatible Terraform or provider versions, ensuring stability across different environments.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Which file should contain the `terraform { required_version = ... }` block?** (`versions.tf`)
2.  **True/False: Descriptions in `variables.tf` are mandatory but ignored by Terraform.** (False - They are optional but highly recommended for documentation)
3.  **What is the purpose of the `examples/` directory?** (To show users how to correctly call the module)
4.  **Should you put your `provider` configuration (e.g. AWS keys) inside a reusable module?** (No - Providers should be passed from the Root Module)
5.  **What happens if a module has a `main.tf` but no `variables.tf`?** (The module is static; it will always deploy exactly the same thing)
