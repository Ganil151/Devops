Data sources allow Terraform to use information defined outside of Terraform, or defined by another separate Terraform configuration.

## Basic Syntax
```hcl
data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

resource "aws_instance" "app" {
  ami = data.aws_ami.latest.id
  ...
}
```

## Common Use Cases
- Querying the list of available Availability Zones.
- Fetching the ID of an existing VPC.
- Retrieving the latest OS image (AMI).
- Reading secrets from AWS Secrets Manager.

---
## 🏗️ Real-Life Scenario: Scaling to a New Region
**Problem**: You have a hardcoded AMI ID in your code. When you try to deploy to a different region, the AMI doesn't exist, and the deployment fails.
**Solution**: Use an `aws_ami` **Data Source**. This will dynamically search for the correct AMI ID in whatever region you are targeting, making your code portable.

---
## ❓ Interview Questions
1. **What is the main difference between a Data Source and a Resource?**
   - *Answer*: A Resource creates/manages infrastructure (Write); a Data Source fetches information from existing infrastructure (Read).
2. **Can you use data from one Terraform project in another?**
   - *Answer*: Yes, using the `terraform_remote_state` data source.

---

## 🧠 Quiz Snippet (5/20+)
1. **Does a data source block create infrastructure?** (No)
2. **What keyword starts a data block?** (`data`)
3. **If a data source fails to find a match, what happens?** (Terraform errors during plan/apply)
4. **True/False: Data sources are read-only.** (True)
5. **How do you filter results in a data source?** (using the `filter` block)
