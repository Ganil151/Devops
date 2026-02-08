# 08. Shared VPC (RAM)
# A VPC shared across accounts within an AWS Organization.

resource "aws_vpc" "shared_vpc" {
  cidr_block = "10.50.0.0/16"
  
  tags = {
    Name = "Corporate-Shared-VPC"
  }
}

resource "aws_subnet" "shared_subnet" {
  vpc_id     = aws_vpc.shared_vpc.id
  cidr_block = "10.50.1.0/24"
  
  tags = {
    Name = "Shared-Subnet-A"
  }
}

# Share the subnet with other accounts via RAM
resource "aws_ram_resource_share" "vpc_share" {
  name                      = "vpc-resource-share"
  allow_external_principals = false

  tags = {
    Name = "Subnet-Resource-Share"
  }
}

resource "aws_ram_resource_association" "subnet_assoc" {
  resource_arn       = aws_subnet.shared_subnet.arn
  resource_share_arn = aws_ram_resource_share.vpc_share.arn
}
