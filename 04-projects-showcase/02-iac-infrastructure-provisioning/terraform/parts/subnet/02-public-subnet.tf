# 02. Public Subnet
# A subnet with "map_public_ip_on_launch" enabled, intended for IGW routing.

resource "aws_subnet" "public" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-1A"
    Tier = "Public"
  }
}
