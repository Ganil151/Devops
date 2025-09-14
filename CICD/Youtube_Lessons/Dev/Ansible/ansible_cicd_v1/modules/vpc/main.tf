data "aws_availability_zones" "available" {}

resource "aws_vpc" "cicd_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "cicd_vpc"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.cicd_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "cicd_public_${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.cicd_vpc.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "cicd_private_${count.index + 1}"
  }
}

resource "aws_internet_gateway" "cicd_igw" {
  vpc_id = aws_vpc.cicd_vpc.id
  tags = {
    Name = "cicd_igw"
  }
}

resource "aws_route_table" "cicd_public_rt" {
  vpc_id = aws_vpc.cicd_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cicd_igw.id
  }

  tags = {
    Name = "cicd_public_rt"
  }
}

resource "aws_subnet" "cicd_public_subnet" {
  vpc_id = aws_vpc.cicd_vpc.id
  cidr_block = var.subnet_cidr_block
  map_public_ip_on_launch = true  

  tags = {
    Name = "cicd_public_subnet"
  }
}

resource "aws_route_table_association" "cicd_rta" {
  count = length(aws_subnet.public_subnets)
  subnet_id = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.cicd_public_rt.id  
}