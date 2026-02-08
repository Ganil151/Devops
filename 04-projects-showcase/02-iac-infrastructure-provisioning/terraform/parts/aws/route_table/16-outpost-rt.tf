# 16. Outpost Route Table
# Routing for subnets on AWS Outposts.

resource "aws_route_table" "outpost" {
  vpc_id = var.vpc_id

  tags = {
    Name = "Outpost-RT"
  }
}

# (Routes would include connectivity to local network gateway)
