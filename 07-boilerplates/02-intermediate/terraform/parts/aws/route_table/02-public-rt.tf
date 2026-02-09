# 02. Public Route Table
# Route to the internet through an Internet Gateway (IGW).

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = "Public-RT"
    Tier = "Public"
  }
}
