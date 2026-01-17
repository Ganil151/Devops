# 🛠️ HCL & IaC Challenges

## Challenge 1: Dynamic Loops with `for_each`
**Objective**: Create multiple S3 buckets from a list.
1.  Define `variable "bucket_names" { type = list(string) }`.
2.  Use `for_each` in an `aws_s3_bucket` resource.
3.  Set the bucket name based on `each.value`.

## Challenge 2: Data Source Filter
**Objective**: Fetch a specific VPC.
1.  Use the `aws_vpc` data source.
2.  Filter by a tag: `Name = "default"`.
3.  Output the `cidr_block` of that VPC.

## Challenge 3: Conditional Logic
**Objective**: Enable/Disable features.
1.  Create a `variable "enable_logging" { type = bool }`.
2.  Create an `aws_s3_bucket` for logs *only if* `enable_logging` is `true`.
3.  Hint: Use `count = var.enable_logging ? 1 : 0`.
