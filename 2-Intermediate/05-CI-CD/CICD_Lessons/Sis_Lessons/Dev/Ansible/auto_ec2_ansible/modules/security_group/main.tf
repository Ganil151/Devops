# SPMS Master SG
resource "aws_security_group" "spms_sg" {
  name        = "spms_sg"
  description = "Allow traffic for SPMS Master"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["186.6.242.96/32"]
  }

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SPMS UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "spms_sg"
  }
}

# spms Worker SG
resource "aws_security_group" "spms_wk_sg" {
  name        = "spms_wk_sg"
  description = "Allow traffic for SPMS Master"
  vpc_id      = var.vpc_id

    ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "spms_wk_sg"
  }
}

# --- Cross SG rules to avoid cycle ---
resource "aws_security_group_rule" "allow_master_to_worker_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.spms_sg.id
  security_group_id        = aws_security_group.spms_wk_sg.id
}

resource "aws_security_group_rule" "allow_worker_to_master_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.spms_wk_sg.id
  security_group_id        = aws_security_group.spms_sg.id
}

resource "aws_security_group_rule" "allow_worker_to_master_icmp" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.spms_wk_sg.id
  security_group_id        = aws_security_group.spms_sg.id
}
