# 03. Public VPC
# A VPC where all subnets have direct access to the internet via an Internet Gateway.

resource "aws_vpc" "public_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "Public-Facing-VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.public_vpc.id

  tags = {
    Name = "Main-IGW"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.public_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.public_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
