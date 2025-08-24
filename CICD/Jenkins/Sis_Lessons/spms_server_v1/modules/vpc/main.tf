resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }

  depends_on = [aws_vpc.jenkins_vpc]
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  count      = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.jenkins_vpc.id
  cidr_block = element(var.private_subnet_cidrs, count.index)

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
  }

  depends_on = [aws_vpc.jenkins_vpc]
}

# Internet Gateway
resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Route Table
resource "aws_route_table" "jenkins_route_table" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }

  tags = {
    Name = "${var.project_name}-route-table"
  }
}

# Route Table Associations
resource "aws_route_table_association" "jenkins_rta" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.jenkins_route_table.id
}