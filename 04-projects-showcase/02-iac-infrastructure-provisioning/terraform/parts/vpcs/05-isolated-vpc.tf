# 05. Isolated VPC
# A VPC with no internet access (no IGW, no NAT). Purely internal traffic.

resource "aws_vpc" "isolated_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "Isolated-Secure-VPC"
  }
}

resource "aws_subnet" "isolated_subnet" {
  vpc_id     = aws_vpc.isolated_vpc.id
  cidr_block = "172.16.1.0/24"

  tags = {
    Name = "Isolated-Subnet"
  }
}

# No internet-bound routes are defined here.
resource "aws_route_table" "isolated_rt" {
  vpc_id = aws_vpc.isolated_vpc.id

  tags = {
    Name = "Isolated-Route-Table"
  }
}

resource "aws_route_table_association" "isolated_assoc" {
  subnet_id      = aws_subnet.isolated_subnet.id
  route_table_id = aws_route_table.isolated_rt.id
}
