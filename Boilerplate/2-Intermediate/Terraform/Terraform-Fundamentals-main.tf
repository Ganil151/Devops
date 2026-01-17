# -----------------------------------------------------------------------------
# Name: main.tf
# Description: Minimal Terraform Configuration for AWS.
# -----------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 1. Provider Configuration
provider "aws" {
  region = "us-east-1"
}

# 2. Resource Definition
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 (Verify in your region)
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}

# 3. Output - Getting data back
output "instance_ip" {
  value = aws_instance.web.public_ip
}
