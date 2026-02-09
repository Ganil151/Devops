# 16. Dual-Stack Subnet
# Subnet supporting both IPv4 and IPv6 addressing.

resource "aws_subnet" "dual_stack" {
  vpc_id                          = var.vpc_id
  cidr_block                      = "10.0.50.0/24"
  ipv6_cidr_block                 = cidrsubnet(var.ipv6_vpc_cidr, 8, 6)
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "Dual-Stack-IPv4-IPv6-Subnet"
  }
}
