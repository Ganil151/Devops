# 🛠️ Terraform Modules Challenges

## Challenge 1: Construct a Module
**Objective**: Build your first reusable module.
1.  Create a folder `modules/s3_static_site`.
2.  Inside, put `main.tf` to create an S3 bucket with website configuration.
3.  Define `variables.tf` for the bucket name.
4.  Define `outputs.tf` to return the website endpoint.

## Challenge 2: Module Versioning
**Objective**: Use a specific version of a public module.
1.  Go to the [Terraform Registry](https://registry.terraform.io/).
2.  Find the `terraform-aws-modules/vpc/aws` module.
3.  Add it to your `main.tf` but pin it to a specific version (e.g., `~> 5.0`).
4.  Run `terraform init`.

## Challenge 3: Module Inter-dependency
**Objective**: Pass output from one module as input to another.
1.  Use a VPC module to create a network.
2.  Use a Security Group module.
3.  Pass the `vpc_id` output from the first module into the second.
