# 04. Isolated Subnet
# Strictly no internet access (no IGW, no NAT). 
# Used for backend systems that require the highest isolation.

resource "aws_subnet" "isolated" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.100.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Isolated-Subnet-1A"
    Tier = "Isolated"
  }
}
