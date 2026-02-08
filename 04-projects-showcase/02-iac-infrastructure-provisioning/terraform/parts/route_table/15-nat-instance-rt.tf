# 15. NAT Instance Route Table (Legacy/Specialist)
# Route traffic through a custom EC2 NAT instance.

resource "aws_route_table" "nat_instance" {
  vpc_id = var.vpc_id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = var.nat_instance_eni_id
  }

  tags = {
    Name = "NAT-Instance-RT"
  }
}
