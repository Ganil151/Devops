terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bobby"
    region         = "us-east-1"
    key            = "s3-github-actions/terraform.tfstate"
    encrypt = true
  }
  required_version = ">=1.0"
  required_providers {
    aws = {
      version = "~> 6.0"
      source = "hashicorp/aws"
    }
  }
}