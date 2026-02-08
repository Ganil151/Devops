# 07. Outbound Only Security Group
# No inbound traffic allowed, but full outbound access.

resource "aws_security_group" "outbound_only" {
  name        = "outbound-only-sg"
  description = "Blocks all inbound, allows all outbound"
  vpc_id      = var.vpc_id

  # Ingress block is empty by default

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Outbound-Only-SG"
  }
}
