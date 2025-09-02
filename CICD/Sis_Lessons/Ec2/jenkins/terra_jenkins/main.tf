terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "foo" {
  ami = "ami-08a6efd148b1f7504"
  instance_type = "t3.micro"

  tags = {
    Name = "TF-Instance"
  }
}

