# 20. Minimalist Route Table
# Baseline empty route table.

resource "aws_route_table" "baseline" {
  vpc_id = var.vpc_id

  tags = {
    Name = "Baseline-RT"
  }
}
