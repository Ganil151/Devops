# 15. IPv6-Only Subnet
# IPv6-native subnet where resources only have an IPv6 address.

resource "aws_subnet" "ipv6_only" {
  vpc_id                          = var.vpc_id
  ipv6_native                     = true
  ipv6_cidr_block                 = cidrsubnet(var.ipv6_vpc_cidr, 8, 5)
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "IPv6-Native-Subnet"
  }
}
