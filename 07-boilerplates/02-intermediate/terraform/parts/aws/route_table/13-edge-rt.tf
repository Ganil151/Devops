# 13. Edge Association Route Table
# Used with Gateway Load Balancer and VPC ingress routing.

resource "aws_route_table" "edge" {
  vpc_id = var.vpc_id

  tags = {
    Name = "Edge-Ingress-RT"
  }
}

# (Specific ingress/egress routes would be added via aws_route)
