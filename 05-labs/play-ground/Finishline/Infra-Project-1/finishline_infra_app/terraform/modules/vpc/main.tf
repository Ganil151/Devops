# =============================================================================
# VPC Module
# Module: vpc
# Assignment Reference: Finish Line 2026 §51, §55, §56, §57
# - VPC with 3 subnets across 3 Availability Zones
# - Internet Gateway (IGW)
# - Public and Private Route Tables
# =============================================================================

# =============================================================================
# VPC
# =============================================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge({
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.manage_by
  }, var.additional_tags)
}

# =============================================================================
# Internet Gateway
# =============================================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.manage_by
  }, var.additional_tags)
}

# =============================================================================
# Public Subnets (3 subnets across 3 AZs)
# Assignment: §51, §55 (Exactly 3 subnets)
# =============================================================================

resource "aws_subnet" "public" {
  count             = length(var.public_subnets_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = merge({
    Name        = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.manage_by
    Type        = "public"
    # EKS cluster tagging requirement
    "kubernetes.io/cluster/${var.project_name}-${var.environment}-eks" = "shared"
    "kubernetes.io/role/elb"                                           = "1"
  }, var.additional_tags)
}

# =============================================================================
# Private Subnets (3 subnets across 3 AZs)
# Assignment: §51, §55 (Exactly 3 subnets)
# =============================================================================

resource "aws_subnet" "private" {
  count             = length(var.private_subnets_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge({
    Name        = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.manage_by
    Type        = "private"
    # EKS cluster tagging requirement
    "kubernetes.io/cluster/${var.project_name}-${var.environment}-eks" = "shared"
    "kubernetes.io/role/internal-elb"                                  = "1"
  }, var.additional_tags)
}

# =============================================================================
# Elastic IP for NAT Gateway
# =============================================================================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge({
    Name        = "${var.project_name}-${var.environment}-nat-eip"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.manage_by
  }, var.additional_tags)

  depends_on = [aws_internet_gateway.main]
}

# =============================================================================
# NAT Gateway (in first public subnet)
# =============================================================================

resource "aws_nat_gateway" "main" {
  count         = 1
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge({
    Name        = "${var.project_name}-${var.environment}-natgw"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.manage_by
  }, var.additional_tags)

  depends_on = [aws_internet_gateway.main]
}

# =============================================================================
# Public Route Table
# =============================================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge({
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.manage_by
    Type        = "public"
  }, var.additional_tags)
}

# =============================================================================
# Private Route Table
# =============================================================================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main[0].id
  }

  tags = merge({
    Name        = "${var.project_name}-${var.environment}-private-rt"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.manage_by
    Type        = "private"
  }, var.additional_tags)
}

# =============================================================================
# Route Table Associations - Public Subnets
# =============================================================================

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# =============================================================================
# Route Table Associations - Private Subnets
# =============================================================================

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# =============================================================================
# VPC Flow Logs (Optional - for security compliance)
# =============================================================================

# resource "aws_flow_log" "main" {
#   count                = var.enable_flow_logs ? 1 : 0
#   iam_role_arn         = aws_iam_role.flow_logs[0].arn
#   log_destination      = aws_cloudwatch_log_group.flow_logs[0].arn
#   traffic_type         = "ALL"
#   vpc_id               = aws_vpc.main.id
# }
