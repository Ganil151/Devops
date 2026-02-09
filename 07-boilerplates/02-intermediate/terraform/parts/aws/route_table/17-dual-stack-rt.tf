# 17. Dual-Stack IPv4/IPv6 Route Table
# Handling both address families.

resource "aws_route_table" "dual_stack" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = var.igw_id
  }

  tags = {
    Name = "Dual-Stack-RT"
  }
}
