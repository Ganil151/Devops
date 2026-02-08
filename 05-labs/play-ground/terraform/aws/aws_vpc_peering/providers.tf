terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = "~> 6.13"
}

provider "aws" {
  region = "us-east-1"
}

