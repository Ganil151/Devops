# 01. Default VPC
# AWS automatically creates a default VPC in each region.
# This resource adopts the default VPC into Terraform management.

resource "aws_default_vpc" "default" {
  tags = {
    Name        = "Default VPC"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

# Documentation: A default VPC is pre-configured with a public subnet in each AZ, 
# an Internet Gateway, and a default security group.
