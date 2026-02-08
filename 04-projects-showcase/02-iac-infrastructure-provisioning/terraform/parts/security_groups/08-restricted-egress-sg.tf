# 08. Restricted Egress Security Group
# Only allows outbound traffic to specific services (e.g., HTTPS for updates).

resource "aws_security_group" "restricted_egress" {
  name        = "restricted-egress-sg"
  description = "Only allows outbound HTTPS"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow only HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Restricted-Egress-SG"
  }
}
