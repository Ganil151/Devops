# 🛠️ State Management Challenges

## Challenge 1: The "Dirty" State Fix
**Objective**: Clean up a corrupted state (Conceptual).
1.  Assume a resource `aws_instance.web` was manually deleted in the AWS Console.
2.  Run `terraform plan`. Observe that Terraform wants to recreate it.
3.  Command: `terraform state rm aws_instance.web`.
4.  Observe that Terraform now forgets about that resource entirely.

## Challenge 2: State Import
**Objective**: Bring Existing Infra under Terraform Control.
1.  Create an S3 bucket manually in the console. 
2.  Add a skeleton resource in your `.tf` file: `resource "aws_s3_bucket" "manual" {}`.
3.  Run `terraform import aws_s3_bucket.manual <bucket-name>`.

## Challenge 3: Backend Migration
**Objective**: Move from local to remote.
1.  Start with a `local` state.
2.  Add the `backend "s3"` block.
3.  Run `terraform init`.
4.  Type `yes` when asked to migrate the state to the new backend.
