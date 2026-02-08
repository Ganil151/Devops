# 02. Custom VPC
# A fully customizable VPC where you define the CIDR block and networking features.

resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "Custom-Production-VPC"
    Environment = "Production"
    Project     = "Infrastructure"
  }
}
