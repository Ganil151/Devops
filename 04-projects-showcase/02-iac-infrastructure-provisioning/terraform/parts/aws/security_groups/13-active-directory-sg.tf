# 13. Active Directory Security Group
# Required ports for Windows Domain Controllers.

resource "aws_security_group" "ad_sg" {
  name        = "active-directory-sg"
  description = "Allows AD communication"
  vpc_id      = var.vpc_id

  ingress {
    description = "LDAP"
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "DNS"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "Kerberos"
    from_port   = 88
    to_port     = 88
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Active-Directory-SG"
  }
}
