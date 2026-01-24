# 🛠️ Terraform Fundamentals Challenges

## Challenge 1: The First S3 Bucket
**Objective**: Provision an S3 bucket.
1.  Create `s3.tf`.
2.  Define an `aws_s3_bucket` resource.
3.  Name it uniquely (S3 names are global).
4.  Run `terraform init`, `terraform plan`, and `terraform apply`.

## Challenge 2: Local Variables
**Objective**: Practice variable usage.
1.  Define a `variable "instance_name" {}`.
2.  In `main.tf`, use the variable for the instance tag: `Name = var.instance_name`.
3.  Pass the variable via command line: `terraform plan -var="instance_name=MyWebApp"`.

## Challenge 3: Output Formatting
**Objective**: Extract specific data.
1.  Add an output that prints the Amazon Resource Name (ARN) of your S3 bucket from Challenge 1.
2.  Run `terraform output`.
