# 10. Lambda Compute Subnet
# Optimized for Lambda VPC integration.

resource "aws_subnet" "lambda_compute" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.40.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Lambda-Compute-Subnet"
    Tier = "Compute"
  }
}
