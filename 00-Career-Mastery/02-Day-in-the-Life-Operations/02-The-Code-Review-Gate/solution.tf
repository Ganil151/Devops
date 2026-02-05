# SRE Standard: Clean, Secure, and Variable-Driven
# No provider credentials here (use IAM Instance Profiles or Env Vars)

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "web_server_sg" {
  name        = "${var.project_name}-${var.environment}-web-sg"
  description = "Restricted ingress for Web Servers"
  vpc_id      = var.vpc_id

  # Allow SSH ONLY from our Corporate VPN CIDR
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpn_cidr] 
  }

  # Production Web Traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_instance" "app_node" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  iam_instance_profile   = var.iam_role_name

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-app-01"
  })
}
