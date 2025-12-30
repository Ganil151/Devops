# Creating Modules

Learn how to build a module from scratch with input validation and professional patterns.

## Step-by-Step: Building an S3 Module

### 1. Variables (The Interface)
Use type constraints and validation to prevent "Garbage In, Garbage Out."
```hcl
variable "bucket_name" {
  type        = string
  description = "Name of the bucket"
  
  validation {
    condition     = length(var.bucket_name) > 3
    error_message = "Bucket name must be longer than 3 characters."
  }
}
```

### 2. Main Logic (The Implementation)
Use `locals` to keep your code DRY (Don't Repeat Yourself).
```hcl
locals {
  tags = merge(var.custom_tags, { ManagedBy = "Terraform" })
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = local.tags
}
```

### 3. Outputs (The Result)
```hcl
output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}
```

## Best Practice: Variable Validation
Always validate your inputs! For example, ensuring an environment name is only "dev", "staging", or "prod" prevents illegal deployments.

---

## 🏗️ Real-Life Scenario: The Typo that Cost $1,000
**Problem**: A module for an EC2 instance allows any `instance_type` string. A developer typos `t3.large` as `m5.metal`.
**Outcome**: Terraform successfully creates the massive, expensive instance.
**Solution**: Add a `validation` block in `variables.tf` that checks if the string is in an allowed list of "Cheap" instances. Now, the `plan` fails immediately before the money is spent.

---

## ❓ Interview Questions
1.  **How do you handle default values in a module?**
    *   *Answer*: You define them in the `variable` block. If a user doesn't provide a value, the default is used. If no default is provided, the variable becomes "Required."
2.  **What is the benefit of using `locals` in a module?**
    *   *Answer*: They allow you to perform complex logic or string manipulations once and reuse the result multiple times, keeping the resource blocks clean.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Which block is used to ensure a variable matches a specific pattern?** (`validation`)
2.  **True/False: You can use `locals` to store secrets.** (Technically yes, but they still appear in state)
3.  **What is the reserved word to call a module?** (`module`)
4.  **Can a module access variables from the Root Module directly?** (No - They must be explicitly passed as arguments)
5.  **What happens if you provide a variable to a module that isn't defined in its `variables.tf`?** (Terraform returns an error)
