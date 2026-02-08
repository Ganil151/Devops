# 12. Bastion Host Security Group
# Specifically for a jump host with restricted SSH.

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-host-sg"
  description = "Security Group for Bastion/Jump Host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.5/32"] # Restricted to a single admin IP
  }

  egress {
    description = "Allow SSH to internal instances"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "Bastion-Host-SG"
  }
}
