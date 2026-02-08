resource "aws_vpc" "primary_vpc" {
  cidr_block           = var.primary_vpc_cidr
  provider             = aws.primary
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Primary-VPC-${var.primary}"
  }
}

resource "aws_vpc" "secondary_vpc" {
  cidr_block           = var.secondary_vpc_cidr
  provider             = aws.secondary
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Primary-VPC-${var.primary}"
  }
}

resource "aws_subnet" "primary_subnet" {
  vpc_id     = aws_vpc.primary_vpc.id
  cidr_block = var.primary_subnet_cidr
  availability_zone = data.aws_availability_zones.primary.names[0]
  map_public_ip_on_launch = true
  provider   = aws.primary

  tags = {
    Name = "Primary-Subnet-${var.primary}"
    Environment = var.environment
  }
} 

resource "aws_subnet" "secondary_subnet" {
  
}