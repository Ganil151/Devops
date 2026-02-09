# 01. Default Route Table
# Adopts the main route table created by AWS for the VPC.

resource "aws_default_route_table" "main" {
  default_route_table_id = var.main_route_table_id

  tags = {
    Name        = "Default-Route-Table"
    Environment = "Dev"
  }
}
