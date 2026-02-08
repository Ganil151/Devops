# 06. VPC Peering Route Table
# Route traffic to a peered VPC.

resource "aws_route_table" "peering" {
  vpc_id = var.vpc_id

  route {
    cidr_block                = "10.1.0.0/16" # Peered VPC CIDR
    vpc_peering_connection_id = var.peering_id
  }

  tags = {
    Name = "VPC-Peering-RT"
  }
}
