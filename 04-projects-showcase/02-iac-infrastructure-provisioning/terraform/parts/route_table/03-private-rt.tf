# 03. Private Route Table
# Route to the internet through a NAT Gateway (NATGW).

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gw_id
  }

  tags = {
    Name = "Private-RT"
    Tier = "Private"
  }
}
