Variables allow you to parameterize your configurations, while Outputs let you extract information about your infrastructure.

## Input Variables
```hcl
variable "instance_type" {
  description = "Size of EC2"
  type        = string
  default     = "t3.micro"
}
```
## Output Values
```hcl
output "public_ip" {
  value = aws_instance.web.public_ip
}
```
## Variable Validation
You can enforce rules on your variables to prevent invalid configurations.
```hcl
variable "env" {
  validation {
    condition     = contains(["dev", "prod"], var.env)
    error_message = "Environment must be dev or prod."
  }
}
```

---
## 🏗️ Real-Life Scenario: The Secret Leak
**Problem**: A developer outputs a database password in the CLI, and it's visible in the logs.
**Solution**: Use the `sensitive = true` flag in your variables and outputs.
```hcl
variable "db_pass" {
  sensitive = true
}
output "db_pass" {
  value     = var.db_pass
  sensitive = true
}
```
Terraform will mask the value with `<sensitive>` in the console output.

---

## ❓ Interview Questions
1. **List three ways to pass variables to Terraform.**
   - *Answer*: 1. `-var` CLI flag. 2. `terraform.tfvars` file. 3. Environment variables (prefixed with `TF_VAR_`).
2. **What is the priority of variable sources?**
   - *Answer*: Environment variables < `terraform.tfvars` < `*.auto.tfvars` < `-var` or `-var-file` flags.

---

## 🧠 Quiz Snippet (5/20+)
1. **Which flag masks output values?** (`sensitive = true`)
2. **How do you define a default value for a variable?** (using the `default` attribute)
3. **Can an output value be used by other resources in the same file?** (Yes, via reference)
4. **What is the file extension for variable definitions?** (`.tfvars`)
5. **Which environment variable prefix does Terraform use?** (`TF_VAR_`)
