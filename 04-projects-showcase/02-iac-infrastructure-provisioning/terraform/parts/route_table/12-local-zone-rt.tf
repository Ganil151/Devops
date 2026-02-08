# 12. Local Zone Route Table
# Specifically for resources in an AWS Local Zone.

resource "aws_route_table" "local_zone" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = "Local-Zone-RT"
  }
}
