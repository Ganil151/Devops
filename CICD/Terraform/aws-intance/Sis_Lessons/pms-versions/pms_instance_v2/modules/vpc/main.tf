# Create the VPC
resource "aws_vpc" "petclinic_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "petclinic_igw" {
  vpc_id = aws_vpc.petclinic_vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Create a public subnet
resource "aws_subnet" "petclinic_subnet" {
  vpc_id                  = aws_vpc.petclinic_vpc.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-subnet"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "petclinic_route_table" {
  vpc_id = aws_vpc.petclinic_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.petclinic_igw.id
  }

  tags = {
    Name = "${var.vpc_name}-route-table"
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "petclinic_rt_assoc" {
  subnet_id      = aws_subnet.petclinic_subnet.id
  route_table_id = aws_route_table.petclinic_route_table.id
}