# 18. High-Density Subnet
# Larger CIDR range for environments with thousands of containers or small workloads.

resource "aws_subnet" "high_density" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.64.0/20" # 4096 addresses
  availability_zone = "us-east-1a"

  tags = {
    Name = "Scale-Out-Container-Subnet"
    Density = "High"
  }
}
