# 05. Transit Gateway Route Table
# Used for connecting multiple VPCs and on-premises networks.

resource "aws_route_table" "tgw" {
  vpc_id = var.vpc_id

  route {
    cidr_block         = "10.0.0.0/8" # Organizations CIDR
    transit_gateway_id = var.tgw_id
  }

  tags = {
    Name = "Transit-Gateway-RT"
  }
}
