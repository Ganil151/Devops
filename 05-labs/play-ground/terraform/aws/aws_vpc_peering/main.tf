resource "aws_vpc" "primary_vpc" {
  cidr_block           = var.primary_vpc_cidr
  provider             = aws.primary
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Primary-VPC-${var.primary}"
  }
}

resource "aws_vpc" "secondary_vpc" {
  cidr_block           = var.secondary_vpc_cidr
  provider             = aws.secondary
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Primary-VPC-${var.primary}"
  }
}

resource "aws_subnet" "primary_subnet" {
  vpc_id                  = aws_vpc.primary_vpc.id
  cidr_block              = var.primary_subnet_cidr
  availability_zone       = data.aws_availability_zones.primary.names[0]
  map_public_ip_on_launch = true
  provider                = aws.primary

  tags = {
    Name        = "Primary-Subnet-${var.primary}"
    Environment = var.environment
  }
}

resource "aws_subnet" "secondary_subnet" {
  vpc_id                  = aws_vpc.secondary_vpc.id
  cidr_block              = var.secondary_subnet_cidr
  availability_zone       = data.aws_availability_zones.secondary.names[0]
  map_public_ip_on_launch = true
  provider                = aws.secondary

  tags = {
    Name        = "Secondary-Subnet-${var.secondary}"
    Environment = var.environment
  }

}

resource "aws_internet_gateway" "primary_igw" {
  vpc_id   = aws_vpc.primary_vpc.id
  provider = aws.primary

  tags = {
    Name = "Primary-IGW-${var.primary}"
  }
}

resource "aws_internet_gateway" "secondary_igw" {
  vpc_id   = aws_vpc.secondary_vpc.id
  provider = aws.secondary

  tags = {
    Name = "Secondary-IGW-${var.secondary}"
  }
}

resource "aws_route_table" "primary_route_table" {
  vpc_id   = aws_vpc.primary_vpc.id
  provider = aws.primary

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_igw.id
  }

  tags = {
    Name = "Primary-Route-Table-${var.primary}"
  }
}

resource "aws_route_table" "secondary_route_table" {
  vpc_id   = aws_vpc.secondary_vpc.id
  provider = aws.secondary

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary_igw.id
  }

  tags = {
    Name = "Secondary-Route-Table-${var.secondary}"
  }
}


resource "aws_route_table_association" "primary_rtb" {
  subnet_id      = aws_subnet.primary_subnet.id
  route_table_id = aws_route_table.primary_route_table.id
  provider       = aws.primary

}

resource "aws_route_table_association" "secondary_rtb" {
  subnet_id      = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.secondary_route_table.id
  provider       = aws.secondary
}


resource "aws_vpc_peering_connection" "primary_to_secondary" {
  provider = aws.primary
  vpc_id = aws_vpc.primary_vpc.id
  pe
}