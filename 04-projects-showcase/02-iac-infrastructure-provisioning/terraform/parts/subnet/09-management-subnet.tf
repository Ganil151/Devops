# 09. Management Subnet
# Small subnet reserved for bastion hosts or management infrastructure.

resource "aws_subnet" "mgmt" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.250.0/28" # Very small range
  availability_zone = "us-east-1a"

  tags = {
    Name = "Management-Bastion-Subnet"
    Tier = "Management"
  }
}
