# 20. Minimalist VPC
# A lightweight configuration with only the essential components.

resource "aws_vpc" "minimalist" {
  cidr_block = "10.0.0.0/24" # Small CIDR for POC

  tags = {
    Name = "POC-Minimalist-VPC"
  }
}

resource "aws_subnet" "poc_subnet" {
  vpc_id     = aws_vpc.minimalist.id
  cidr_block = "10.0.0.0/28" # Just 16 addresses
  
  tags = {
    Name = "Single-POC-Subnet"
  }
}
