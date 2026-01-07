terraform {
  # S3 Backend Configuration for Remote State Storage
  backend "s3" {
    bucket         = "gsmash-demo-bucket-name-123456"  # S3 bucket to store state file
    key            = "dev/terraform.tfstate"           # Path within bucket for state file
    region         = "us-east-1"                       # AWS region for S3 bucket
    encrypt        = true                              # Enable server-side encryption
    dynamodb_table = "gsmash-demo-lock-table"         # DynamoDB table for state locking
  }

  # Required Provider Configuration
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"  # Use AWS provider version 6.x
    }
  }

  # Minimum Terraform version requirement
  required_version = ">= 1.0"
}

# AWS Provider Configuration
provider "aws" {
  region = "us-east-1"
}

