# =============================================================================
# VPC Module - Main Configuration
# Finish Line 2026 Infrastructure
# Assignment: §51, §55, §56, §57 - VPC with 3 subnets across 3 AZs
# =============================================================================

# VPC
resource "aws_vpc" "finishline_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-vpc"
    Type = "VPC"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "finishline_igw" {
  vpc_id = aws_vpc.finishline_vpc.id

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-igw"
    Type = "InternetGateway"
  })
}

# Public Subnets (3 across 3 AZs)
resource "aws_subnet" "finishline_public_subnet" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.finishline_vpc.id
  cidr_block              = var.public_subnets_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-public-subnet-${count.index + 1}"
    Type = "PublicSubnet"
    Tier = "public"
  })
}

# Private Subnets (3 across 3 AZs)
resource "aws_subnet" "finishline_private_subnet" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.finishline_vpc.id
  cidr_block        = var.private_subnets_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-private-subnet-${count.index + 1}"
    Type = "PrivateSubnet"
    Tier = "private"
  })
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.finishline_vpc.id

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-public-rt"
    Type = "RouteTable"
  })
}

# Default route to Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.finishline_igw.id
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.finishline_public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.finishline_vpc.id

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-private-rt"
    Type = "RouteTable"
  })
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.finishline_private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}

# =============================================================================
# NAT Gateway for Private Subnet Internet Access
# =============================================================================

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-nat-eip"
    Type = "EIP"
  })
}

# NAT Gateway (placed in first public subnet)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.finishline_public_subnet[0].id

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-nat-gateway"
    Type = "NATGateway"
  })

  depends_on = [aws_internet_gateway.finishline_igw]
}

# Private subnet route to NAT Gateway for internet access
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}
