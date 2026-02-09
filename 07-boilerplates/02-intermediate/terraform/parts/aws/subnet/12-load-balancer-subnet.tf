# 12. Load Balancer Subnet
# Dedicated public subnets for Application Load Balancers.

resource "aws_subnet" "alb" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false # ALBs have their own public IP mapping logic

  tags = {
    Name = "ALB-Public-Subnet"
    Tier = "LoadBalancer"
  }
}
