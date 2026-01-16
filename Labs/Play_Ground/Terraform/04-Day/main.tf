terraform {

  backend "s3" {
    bucket         = "gsmash-demo-bucket-name-123456"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "gsmash-demo-lock-table"  # Correct way to enable locking
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# create s3 bucket
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "gsmash-demo-bucket-name-123456"
  
  tags = {
    Name        = "MyBucket 2.0"
    Environment = "Dev"
  }
}