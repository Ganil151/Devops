# 10. Direct Connect Route Table
# Route traffic to on-premises via AWS Direct Connect.

resource "aws_route_table" "dx" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "172.16.0.0/12" # Corporate network
    gateway_id = var.dx_gw_id
  }

  tags = {
    Name = "Direct-Connect-RT"
  }
}
