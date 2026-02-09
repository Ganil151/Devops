# 17. Highly Available VPC
# Designed for fault tolerance by spanning multiple Availability Zones.

resource "aws_vpc" "ha_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = { Name = "HA-VPC" }
}

# Subnets across 3 Availability Zones
resource "aws_subnet" "public_az1" {
  vpc_id            = aws_vpc.ha_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public_az2" {
  vpc_id            = aws_vpc.ha_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "public_az3" {
  vpc_id            = aws_vpc.ha_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"
}

# Multi-AZ NAT Gateways (One per AZ for maximum resilience)
# (Omitted here for brevity, but a common practice for true HA)
