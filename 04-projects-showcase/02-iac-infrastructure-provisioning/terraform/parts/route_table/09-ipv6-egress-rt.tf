# 09. IPv6 Egress-Only Route Table
# Route for outbound-only IPv6 traffic.

resource "aws_route_table" "ipv6_egress" {
  vpc_id = var.vpc_id

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = var.eigw_id
  }

  tags = {
    Name = "IPv6-Egress-Only-RT"
  }
}
