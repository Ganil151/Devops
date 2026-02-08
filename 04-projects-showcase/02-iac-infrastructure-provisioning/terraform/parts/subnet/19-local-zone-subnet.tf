# 19. Local Zone Subnet
# Low-latency subnet deployed in an AWS Local Zone (e.g., Los Angeles).

resource "aws_subnet" "local_zone" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.70.0/24"
  availability_zone = "us-west-2-lax-1a"

  tags = {
    Name = "Edge-Local-Zone-Subnet"
  }
}
