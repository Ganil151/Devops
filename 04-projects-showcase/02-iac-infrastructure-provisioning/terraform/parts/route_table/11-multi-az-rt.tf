# 11. Multi-AZ Private Route Tables
# Separate route tables per AZ for high availability NAT.

resource "aws_route_table" "private_az1" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gw_az1_id
  }

  tags = {
    Name = "Private-RT-AZ1"
  }
}

resource "aws_route_table" "private_az2" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gw_az2_id
  }

  tags = {
    Name = "Private-RT-AZ2"
  }
}
