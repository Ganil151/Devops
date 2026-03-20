#============================================================
#  VPC Resource
#============================================================
resource "aws_vpc" "finishline_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managed_by
  }
}

#============================================================
#  Internet Gateway Resource
#============================================================
resource "aws_internet_gateway" "finishline_igw" {
  vpc_id = aws_vpc.finishline_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managed_by
  }
}
#============================================================
#  EIP Gateway Resource
#============================================================
resource "aws_eip" "main" {
  domain = "vpc"
}
#============================================================
#  NAT Gateway Resources
#============================================================
resource "aws_nat_gateway" "finishline_nat_gw" {
  subnet_id     = aws_subnet.finishline_public_subnet[0].id
  allocation_id = aws_eip.main.id

  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-${var.environment}-nat-gw"
    Environment = var.environment
  })

}

#============================================================
#  Subnet Resources
#============================================================
resource "aws_subnet" "finishline_public_subnet" {
  count = length(var.public_subnet_cidr)

  vpc_id                  = aws_vpc.finishline_vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managed_by
    Type        = "public"
  }
}
resource "aws_route_table" "finishline_public_rt" {
  vpc_id = aws_vpc.finishline_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managed_by
  }
}

resource "aws_route" "finishline_public_route" {
  route_table_id         = aws_route_table.finishline_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.finishline_igw.id
}

resource "aws_route_table_association" "finishline_public" {
  count = length(var.public_subnet_cidr)

  subnet_id      = aws_subnet.finishline_public_subnet[count.index].id
  route_table_id = aws_route_table.finishline_public_rt.id
}

#============================================================
#  Private Subnet Resource
#============================================================
resource "aws_subnet" "finishline_private_subnet" {
  count = length(var.private_subnet_cidr)

  vpc_id            = aws_vpc.finishline_vpc.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managed_by
    Type        = "private"
  }
}

resource "aws_route_table" "finishline_private_rt" {
  vpc_id = aws_vpc.finishline_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-rt"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managed_by
  }
}

resource "aws_route" "finishline_private_route" {
  route_table_id         = aws_route_table.finishline_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.finishline_nat_gw.id
}

resource "aws_route_table_association" "finishline_private" {
  count = length(var.private_subnet_cidr)

  subnet_id      = aws_subnet.finishline_private_subnet[count.index].id
  route_table_id = aws_route_table.finishline_private_rt.id
}
#============================================================
#  NACL Resource
#============================================================
resource "aws_network_acl" "finishline_nacl" {
  vpc_id     = aws_vpc.finishline_vpc.id
  subnet_ids = concat(aws_subnet.finishline_public_subnet[*].id, aws_subnet.finishline_private_subnet[*].id)

  dynamic "ingress" {
    for_each = local.ingress_rules_transform
    content {
      rule_no    = ingress.value.rule_no
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
    }
  }
  dynamic "egress" {
    for_each = local.egress_rules_transform
    content {
      rule_no    = egress.value.rule_no
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
      protocol   = egress.value.protocol
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-nacl"
  })
}

