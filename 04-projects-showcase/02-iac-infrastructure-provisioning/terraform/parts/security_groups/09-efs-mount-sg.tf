# 09. EFS Mount Security Group
# Allows NFS traffic for EFS mounting.

resource "aws_security_group" "efs_sg" {
  name        = "efs-mount-sg"
  description = "Allows NFS traffic from clients"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EFS-Mount-SG"
  }
}
