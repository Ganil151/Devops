# Basic Examples

Practical examples to get you started with Terraform.

## 1. Simple S3 Bucket
```hcl
resource "aws_s3_bucket" "test_bucket" {
  bucket = "my-unique-bucket-name-12345"
  tags = { Name = "MyBucket" }
}
```

## 2. Web Server with Security Group
```hcl
resource "aws_security_group" "allow_web" {
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_web.id]
}
```

## 3. Using Variables and Outputs
```hcl
variable "region" { default = "us-west-2" }

provider "aws" { region = var.region }

output "region_used" { value = var.region }
```

---

## 🏗️ Real-Life Scenario: The Instant Environment
**Problem**: A QA engineer needs an environment for 2 hours to test a bug fix.
**Solution**: They use the `Basic Example` templates, run `terraform apply`, do their testing, and then run `terraform destroy`. The total cost is pennies, and the environment is perfectly cleaned up.

---

## ❓ Interview Questions
1. **How do you ensure your S3 bucket name is unique in a script?**
   - *Answer*: You can use the `random_id` or `random_string` resource provided by the Random provider.
2. **Can you reference a security group ID before it is created?**
   - *Answer*: Yes, Terraform's dependency graph handles the order. You just reference `aws_security_group.name.id`.

---

## 🧠 Quiz Snippet (5/20+)
1. **Can you manage multiple resources in one block?** (No, one resource per block)
2. **What is 'user_data' in an EC2 resource used for?** (Running scripts on startup)
3. **How do you reference a variable named 'box'?** (`var.box`)
4. **Which provider manages Google Cloud?** (`google`)
5. **What is the command to view output values?** (`terraform output`)
