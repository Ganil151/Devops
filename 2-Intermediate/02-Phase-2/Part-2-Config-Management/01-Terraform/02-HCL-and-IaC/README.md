# HCL (HashiCorp Configuration Language)

HCL is the language of Terraform. It's designed to be human-readable while powerful enough to handle complex infrastructure relationships.

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `advanced_hcl.tf` (Variables, Locals, Data Sources).
- **[CHALLENGES](./CHALLENGES.md)**: Loops (`for_each`) and Conditionals.

---

## 🔑 Key Concepts

| Keyword | Description |
| :--- | :--- |
| **`variable`** | Parameterization. Allows inputs from CLI or `.tfvars`. |
| **`locals`** | Internal variables. Used for DRY (Don't Repeat Yourself) code. |
| **`data`** | Read-only fetch. Pulls info from existing infrastructure. |
| **`output`** | Exports values for users or other Terraform states. |
| **`count`** | Simple loop (incremental index). |
| **`for_each`** | Sophisticated loop (map or set of strings). |

---

## 🏗️ Robust Pattern: Variable Validation
Always validate inputs to catch errors before `apply`.

```hcl
variable "port" {
  type = number
  validation {
    condition     = var.port > 1024
    error_message = "Non-privileged ports (1025+) are required for this app."
  }
}
```

---

## ❓ Interview Questions

1. **What is the difference between `count` and `for_each`?**
   - *Answer*: `count` is based on an index (0, 1, 2). If you remove an item from the middle of the list, Terraform will re-create subsequent items. `for_each` is based on a unique key, making it safer for managing resources in a list.
2. **When would you use `locals` instead of `variables`?**
   - *Answer*: Use `variables` for values provided by the *user* at runtime. Use `locals` for values derived *inside* the code (e.g., combining strings or performing logical calculations).
3. **What are Data Sources used for?**
   - *Answer*: To fetch information about infrastructure that already exists (not managed by the current Terraform workspace), such as the default VPC ID or the latest AMI ID.

---

[Next: State Management](../03-State-Management/README.md)