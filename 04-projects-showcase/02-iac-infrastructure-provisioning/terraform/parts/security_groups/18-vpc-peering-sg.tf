# 18. VPC Peering Security Group
# Allowing communication from a peered VPC's CIDR.

resource "aws_security_group" "peer_sg" {
  name        = "vpc-peering-sg"
  description = "Allows traffic from Peered VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.1.0.0/16"] # Peered VPC CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.1.0.0/16"]
  }

  tags = {
    Name = "VPC-Peering-SG"
  }
}
