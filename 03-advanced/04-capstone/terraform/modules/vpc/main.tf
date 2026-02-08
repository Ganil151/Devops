variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "environment" {
  type = string
  default = "production"
}

variable "availability_zones" {
  type = list(string)
}

# 1. The Virtual Private Cloud
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc-${var.region}"
    Environment = var.environment
  }
}

# 2. Public Subnets (Active)
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-${var.region}-${var.availability_zones[count.index]}"
    "kubernetes.io/role/elb" = "1" # For AWS Load Balancer Controller
  }
}

# 3. Private Subnets (Worker Nodes)
resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-private-${var.region}-${var.availability_zones[count.index]}"
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery" = "${var.environment}-cluster" # For Karpenter scaling
  }
}

# 4. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw-${var.region}"
  }
}

# 5. Route Table (Public)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}-public-rt-${var.region}"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 6. Outputs for Cross-Region Peering
output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}
