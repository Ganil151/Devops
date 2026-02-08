# 03. Private Subnet
# Standard private subnet with no public IP mapping. 
# Usually paired with a NAT Gateway route.

resource "aws_subnet" "private" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-Subnet-1A"
    Tier = "Private"
  }
}
