# 05. Application Tier Security Group
# Accepts traffic from the Load Balancer.

resource "aws_security_group" "app_sg" {
  name        = "app-tier-sg"
  description = "Allows traffic only from the ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Application-Tier-SG"
  }
}
