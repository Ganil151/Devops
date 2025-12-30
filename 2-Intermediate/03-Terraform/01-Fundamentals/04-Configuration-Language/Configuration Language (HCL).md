HashiCorp Configuration Language (HCL) is designed to be human-readable and machine-friendly for defining infrastructure.
## Syntax Basics
```hcl
# Block syntax
resource "resource_type" "local_name" {
  argument_name = "value"
}
```
## Data Types
- **String**: `"t3.micro"`
- **Number**: `10`
- **Boolean**: `true`
- **List**: `["us-east-1a", "us-east-1b"]`
- **Map**: `{ Name = "Web", Env = "Dev" }`

## Functions & Expressions
Terraform provides over 100 built-in functions (no custom functions allowed).
- **upper("hello")** -> "HELLO"
- **element(list, index)** -> retrieves an item.
- **lookup(map, key, default)** -> safe map retrieval.

---
## 🏗️ Real-Life Scenario: Dynamic Naming
**Problem**: An organization needs to tag all resources with the environment name. Hardcoding tags works but is prone to errors.
**Solution**: Use **Locals** and **String Interpolation**.
```hcl
locals {
  name_prefix = "${var.project}-${var.env}"
}
resource "aws_instance" "app" {
  ...
  tags = { Name = "${local.name_prefix}-server" }
}
```

---

## ❓ Interview Questions
1. **What is HCL?**
   - *Answer*: HashiCorp Configuration Language. It is a declarative language used across HashiCorp products like Terraform, Vault, and Nomad.
2. **Can you write custom functions in Terraform?**
   - *Answer*: No, but you can use the wide range of built-in functions provided by HashiCorp.

---

## 🧠 Quiz Snippet (5/20+)
1. **What is the extension for Terraform files?** (`.tf`)
2. **Which data type stores a key-value pair?** (Map)
3. **What is the purpose of 'Locals'?** (To handle internal logic/reusable expressions)
4. **How do you comment a single line in HCL?** (`#` or `//`)
5. **What is interpolation in Terraform?** (The `${...}` syntax to include variables/results in strings)
