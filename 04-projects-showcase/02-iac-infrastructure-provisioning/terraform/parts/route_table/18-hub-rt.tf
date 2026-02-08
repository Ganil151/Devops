# 18. Hub VPC Hub-and-Spoke Route Table
# Routing for a centralized networking hub.

resource "aws_route_table" "hub" {
  vpc_id = var.vpc_id

  # Multiple TGW routes for different spokes
  route {
    cidr_block         = "10.1.0.0/16" # Spoke A
    transit_gateway_id = var.tgw_id
  }

  route {
    cidr_block         = "10.2.0.0/16" # Spoke B
    transit_gateway_id = var.tgw_id
  }

  tags = {
    Name = "Hub-VPC-RT"
  }
}
