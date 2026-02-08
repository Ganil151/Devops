# 19. Cross-Account VPC
# Managing a VPC in a different AWS account via provider Aliases.

provider "aws" {
  alias  = "secondary_account"
  region = "us-west-2"
  assume_role {
    role_arn = "arn:aws:iam::ACCOUNT_ID:role/TerraformRole"
  }
}

resource "aws_vpc" "cross_account_vpc" {
  provider   = aws.secondary_account
  cidr_block = "10.200.0.0/16"

  tags = {
    Name = "VPC-In-Secondary-Account"
  }
}

# Documentation: This demonstrates how to deploy infrastructure into a 
# secondary account using an IAM role assumption.
