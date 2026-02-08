# 09. VPC with Peering
# Connecting two VPCs for private communication.

resource "aws_vpc" "vpc_a" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "VPC-A" }
}

resource "aws_vpc" "vpc_b" {
  cidr_block = "10.1.0.0/16"
  tags       = { Name = "VPC-B" }
}

resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id = aws_vpc.vpc_b.id
  vpc_id      = aws_vpc.vpc_a.id
  auto_accept = true

  tags = {
    Name = "VPC-Peering-A-B"
  }
}
