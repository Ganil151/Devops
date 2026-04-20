resource "aws_security_group" "jumphost-sg" {
  name        = local.jumphost_security_group_name
  description = local.jumphost_security_group_description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }

  }
  dynamic "egress" {
    for_each = local.egress_rules
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = local.common_tags

}

resource "aws_iam_role" "jumphost_role" {
  name = "${var.project_name}-${var.environment}-jumphost-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-jumphost-role"
  })
}

resource "aws_iam_instance_profile" "jumphost_profile" {
  name = "${var.project_name}-${var.environment}-jumphost-profile"
  role = aws_iam_role.jumphost_role.name

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-jumphost-profile"
  })
}
resource "aws_instance" "jumphost" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.jumphost_instance_type
  subnet_id              = var.jumphost_subnet_id
  vpc_security_group_ids = [aws_security_group.jumphost-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.jumphost_profile.name
  key_name               = var.key_pair_name
}
