# 20. Minimalist Subnet
# Smallest possible subnet (/28) for lightweight service isolation.

resource "aws_subnet" "minimalist" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.255.240/28"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Nano-Service-Subnet"
    Tier = "Minimal"
  }
}
