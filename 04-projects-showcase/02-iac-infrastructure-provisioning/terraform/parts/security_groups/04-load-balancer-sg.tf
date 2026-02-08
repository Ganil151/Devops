# 04. Load Balancer Security Group
# Accepts traffic from the internet and passes it to instances.

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allows traffic for the Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress specifically to the App SG
  egress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  tags = {
    Name = "ALB-SG"
  }
}
