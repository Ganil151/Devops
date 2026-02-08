# 18. Egress-Only VPC (IPv6)
# Allow outbound IPv6 traffic while blocking all inbound.

resource "aws_vpc" "egress_vpc" {
  cidr_block                       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
}

resource "aws_egress_only_internet_gateway" "eigw" {
  vpc_id = aws_vpc.egress_vpc.id

  tags = {
    Name = "IPv6-Outbound-Only"
  }
}

resource "aws_subnet" "private_ipv6" {
  vpc_id          = aws_vpc.egress_vpc.id
  cidr_block      = "10.0.1.0/24"
  ipv6_cidr_block = cidrsubnet(aws_vpc.egress_vpc.ipv6_cidr_block, 8, 1)
}

resource "aws_route_table" "egress_rt" {
  vpc_id = aws_vpc.egress_vpc.id

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.eigw.id
  }
}
