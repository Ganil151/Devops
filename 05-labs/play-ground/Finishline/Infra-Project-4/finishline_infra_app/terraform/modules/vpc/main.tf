#============================================================
#  VPC Resource
#============================================================
resource "aws_vpc" "finishline_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
  })
}

#============================================================
#  Internet Gateway Resource
#============================================================
resource "aws_internet_gateway" "finishline_igw" {
  vpc_id = aws_vpc.finishline_vpc.id

  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
  })

}

#============================================================
#  Public Subnet Resource
#============================================================
resource "aws_subnet" "finishline_public_subnet" {
  vpc_id                  = aws_vpc.finishline_vpc.id
  count                   = length(var.public_subnet_cidr)
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = var.availability_zone[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name        = "${local.project_name}-public-subnet-${count.index + 1}"
    Environment = var.environment
  })
}

resource "aws_route" "finishline_public_route" {
  route_table_id         = aws_route_table.finishline_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.finishline_igw.id
}

resource "aws_route_table" "finishline_public_route_table" {
  vpc_id = aws_vpc.finishline_vpc.id

  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-${var.environment}-public-route-table"
    Environment = var.environment
  })
}

resource "aws_route_table_association" "finishline_public_subnet" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.finishline_public_subnet[count.index].id
  route_table_id = aws_route_table.finishline_public_route_table.id
}

#============================================================
#  Public Subnet Resource
#============================================================
resource "aws_subnet" "finishline_private_subnet" {
  vpc_id            = aws_vpc.finishline_vpc.id
  count             = length(var.private_subnet_cidr)
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = merge(local.common_tags, {
    Name        = "${local.project_name}-private-subnet-${count.index + 1}"
    Environment = var.environment
  })

}
resource "aws_route" "finishline_private_route" {
  route_table_id         = aws_route_table.finishline_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.finishline_nat_gw.id
}

resource "aws_route_table" "finishline_private_route_table" {
  vpc_id = aws_vpc.finishline_vpc.id

  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-${var.environment}-private-route-table"
    Environment = var.environment
  })
}

resource "aws_route_table_association" "finishline_private_subnet" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.finishline_private_subnet[count.index].id
  route_table_id = aws_route_table.finishline_private_route_table.id
}

#============================================================
#  EIP Gateway Resource
#============================================================

resource "aws_eip" "finishline_nat_eip" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.finishline_igw]

  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-${var.environment}-nat-eip"
    Environment = var.environment
  })
}

#============================================================
#  NAT Gateway Resource
#============================================================
resource "aws_nat_gateway" "finishline_nat_gw" {
  # Use single NAT Gateway for the first public subnet
  # For HA across multiple AZs, you would need multiple EIPs and NAT Gateways
  subnet_id     = aws_subnet.finishline_public_subnet[0].id
  allocation_id = aws_eip.finishline_nat_eip.id

  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-${var.environment}-nat-gw"
    Environment = var.environment
  })
}

#============================================================
#  Network ACL Resource - Public Subnet 
#============================================================

resource "aws_network_acl" "finishline_network_acl" {
  vpc_id     = aws_vpc.finishline_vpc.id
  subnet_ids = [aws_subnet.finishline_public_subnet[0].id]
  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "icmp"
    rule_no    = 140
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-${var.environment}-public-nacl"
    Environment = var.environment
  })

}

#============================================================
#  Key Pair Module
#============================================================
module "key_pair" {
  source = "../key_pair"

  project_name          = var.project_name
  environment           = var.environment
  managed_by            = var.managed_by
  availability_zone     = var.availability_zone
  key_name              = var.key_name
  key_algorithm         = var.key_algorithm
  rsa_bits              = var.rsa_bits
  file_permission       = var.file_permission
  private_key_filename  = var.private_key_filename
  private_key_directory = var.private_key_directory
  computed_tags         = var.computed_tags
}
