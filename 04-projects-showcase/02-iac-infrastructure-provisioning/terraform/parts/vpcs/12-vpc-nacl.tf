# 12. VPC with Network ACLs
# Subnet-level traffic filtering (stateless).

resource "aws_vpc" "nacl_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_with_nacl" {
  vpc_id     = aws_vpc.nacl_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_network_acl" "custom_nacl" {
  vpc_id     = aws_vpc.nacl_vpc.id
  subnet_ids = [aws_subnet.subnet_with_nacl.id]

  # Allow HTTP Inbound
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # Allow all outbound (Stateless, so must explicitly allow return traffic)
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "Web-Subnet-NACL"
  }
}
