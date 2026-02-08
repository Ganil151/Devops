# 16. IPv6-Enabled VPC
# Supporting dual-stack (IPv4 and IPv6) addressing.

resource "aws_vpc" "ipv6_vpc" {
  cidr_block                       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "Dual-Stack-VPC"
  }
}

resource "aws_subnet" "ipv6_subnet" {
  vpc_id            = aws_vpc.ipv6_vpc.id
  cidr_block        = "10.0.1.0/24"
  ipv6_cidr_block   = cidrsubnet(aws_vpc.ipv6_vpc.ipv6_cidr_block, 8, 1)
  
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "IPv6-Enabled-Subnet"
  }
}
