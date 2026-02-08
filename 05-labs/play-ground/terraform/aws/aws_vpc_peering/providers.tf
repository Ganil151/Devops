terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = "~> 6.0"
}

provider "aws" {
  region = "us-east-1"
  alias = "primary"
}

provider "aws" {
  
}

