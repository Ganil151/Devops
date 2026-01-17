# -----------------------------------------------------------------------------
# Name: backend.tf
# Description: Remote State Configuration with Locking.
# -----------------------------------------------------------------------------

terraform {
  # 1. Remote Backend - MUST be created before use
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    
    # 2. State Locking - Prevents concurrent apply
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

# Tip: Create the S3 bucket and DynamoDB table in a separate 
# "Bootstrap" project first!
