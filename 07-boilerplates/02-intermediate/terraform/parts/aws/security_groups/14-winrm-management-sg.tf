# 14. WinRM Management Security Group
# For remote Windows management.

resource "aws_security_group" "winrm_sg" {
  name        = "winrm-management-sg"
  description = "Allows Windows Remote Management"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5985
    to_port     = 5986
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
    Name = "WinRM-Management-SG"
  }
}
