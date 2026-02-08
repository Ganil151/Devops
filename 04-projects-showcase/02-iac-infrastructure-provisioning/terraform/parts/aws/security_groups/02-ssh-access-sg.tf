# 02. SSH Access Security Group
# Restricted SSH access from specific IP/CIDR.

resource "aws_security_group" "ssh_sg" {
  name        = "ssh-management-sg"
  description = "Allows SSH access from internal office IP"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from Office"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.0/24"] # Example corporate IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH-Management-SG"
  }
}
