# 04. Private VPC
# A VPC where subnets use a NAT Gateway for outbound traffic but are not directly reachable from the internet.

resource "aws_vpc" "private_vpc" {
  cidr_block = "10.1.0.0/16"
  
  tags = {
    Name = "Private-Backend-VPC"
  }
}

# NAT Gateway requires a Public Subnet in a Public VPC or a public tier within this VPC
resource "aws_subnet" "nat_subnet" {
  vpc_id     = aws_vpc.private_vpc.id
  cidr_block = "10.1.1.0/24"
  
  tags = {
    Name = "Subnet-For-NAT"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.nat_subnet.id

  tags = {
    Name = "Main-NAT-Gateway"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.private_vpc.id
  cidr_block = "10.1.2.0/24"

  tags = {
    Name = "Private-Application-Subnet"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.private_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private-Route-Table"
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}
