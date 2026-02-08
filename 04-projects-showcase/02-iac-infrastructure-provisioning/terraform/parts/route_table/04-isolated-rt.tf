# 04. Isolated Route Table
# Internal traffic only, no route to the internet.

resource "aws_route_table" "isolated" {
  vpc_id = var.vpc_id

  # No external routes defined here

  tags = {
    Name = "Isolated-RT"
    Tier = "Isolated"
  }
}
