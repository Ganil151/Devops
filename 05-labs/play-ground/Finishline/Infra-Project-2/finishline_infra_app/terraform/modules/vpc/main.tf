data "aws_availability_zones" "available" {
  state = "available"
}

#========================================================
#  VPC Main Modules
#========================================================
resource "aws_vpc" "finishline_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags                 = local.vpc_tags
}

#========================================================
#  VPC Flow Logs - CloudWatch Log Group
#========================================================
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flowlogs/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = merge(
    local.vpc_tags,
    {
      Name = "${var.project_name}-${var.environment}-vpc-flow-logs"
    }
  )
}

#========================================================
#  VPC Flow Logs - IAM Role
#========================================================
resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "${var.project_name}-${var.environment}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    local.vpc_tags,
    {
      Name = "${var.project_name}-${var.environment}-vpc-flow-logs-role"
    }
  )
}

#========================================================
#  VPC Flow Logs - IAM Policy
#========================================================
resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name = "${var.project_name}-${var.environment}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

#========================================================
#  VPC Flow Logs - Flow Log Resource
#========================================================
resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.finishline_vpc.id

  tags = merge(
    local.vpc_tags,
    {
      Name = "${var.project_name}-${var.environment}-vpc-flow-logs"
    }
  )
}

#========================================================
#  Internet Gateway Modules
#========================================================
resource "aws_internet_gateway" "finishline_igw" {
  vpc_id = aws_vpc.finishline_vpc.id
  tags   = local.igw_tags
}


#========================================================
#  Elastic IP  Modules
#========================================================
resource "aws_eip" "finishline_eip" {
  domain = "vpc"
  tags   = local.eip_tags
}

#========================================================
#  Public Subnet & Route Table Modules
#========================================================
resource "aws_subnet" "finishline_public_subnet" {
  count             = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.finishline_vpc.id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = merge(
    local.subnet_tags,
    {
      Name = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
      Type = "Public"
    }
  )
}

resource "aws_route_table" "finishline_public_route_table" {
  vpc_id = aws_vpc.finishline_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.finishline_igw.id
  }

  tags = merge(
    local.route_table_tags,
    {
      Name = "${var.project_name}-${var.environment}-public-route-table"
      Type = "Public"
    }
  )
}

#========================================================
#  Private Subnet & Route Table Modules
#========================================================
resource "aws_subnet" "finishline_private_subnet" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.finishline_vpc.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = merge(
    local.subnet_tags,
    {
      Name = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
      Type = "Private"
      # EKS cluster tagging requirement
    "kubernetes.io/cluster/${var.project_name}-${var.environment}-${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                                  = "1"
    }
  )
}

resource "aws_route_table" "finishline_private_route_table" {
  vpc_id = aws_vpc.finishline_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.finishline_nat_gateway.id
  }

  tags = merge(
    local.route_table_tags,
    {
      Name = "${var.project_name}-${var.environment}-private-route-table"
      Type = "Private"
    }
  )
}

#========================================================
#  NAT Gateway Modules
#========================================================
resource "aws_nat_gateway" "finishline_nat_gateway" {
  allocation_id = aws_eip.finishline_eip.id
  subnet_id     = aws_subnet.finishline_public_subnet[0].id
  tags          = local.nat_tags
}

#========================================================
#  Network ACL - Public Subnets
#========================================================
resource "aws_network_acl" "finishline_public_nacl" {
  vpc_id     = aws_vpc.finishline_vpc.id
  subnet_ids = aws_subnet.finishline_public_subnet[*].id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
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
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    local.route_table_tags,
    {
      Name = "${var.project_name}-${var.environment}-public-nacl"
      Type = "Public"
    }
  )
}

#========================================================
#  Network ACL - Private Subnets
#========================================================
resource "aws_network_acl" "finishline_private_nacl" {
  vpc_id     = aws_vpc.finishline_vpc.id
  subnet_ids = aws_subnet.finishline_private_subnet[*].id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    local.route_table_tags,
    {
      Name = "${var.project_name}-${var.environment}-private-nacl"
      Type = "Private"
    }
  )
}