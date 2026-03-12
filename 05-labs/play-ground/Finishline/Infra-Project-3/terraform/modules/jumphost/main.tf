# =============================================================================
# Jumphost Module - Main Configuration
# Finish Line 2026 Infrastructure
# Assignment: §69, §70, §73 - AL2023, SSH restriction, tooling installation
# =============================================================================

# Security Group for Jumphost
resource "aws_security_group" "jumphost_sg" {
  name        = "${local.project_name}-jumphost-sg"
  description = "Security group for jumphost with SSH restriction to home IPs"
  vpc_id      = var.vpc_id

  # SSH ingress restricted to home IP CIDRs only
  dynamic "ingress" {
    for_each = var.home_ip_cidrs
    content {
      description = "SSH from ${ingress.value}"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # All outbound traffic allowed
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-jumphost-sg"
    Type = "SecurityGroup"
  })
}

# Jumphost EC2 Instance (Amazon Linux 2023)
resource "aws_instance" "jumphost" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.jumphost_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.jumphost_profile.name
  key_name               = var.key_pair_name

  # Root block device
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  # User data for tool installation
  user_data = file("${path.root}/../../scripts/user_data.sh")

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-jumphost"
    Type = "Jumphost"
    Role = "BastionHost"
  })
}

# Data source for Amazon Linux 2023 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# IAM Instance Profile for Jumphost
resource "aws_iam_instance_profile" "jumphost_profile" {
  name = "${local.project_name}-jumphost-profile"
  role = var.jumphost_role_name

  tags = local.common_tags
}

# Elastic IP for Jumphost
resource "aws_eip" "jumphost_eip" {
  domain   = "vpc"
  instance = aws_instance.jumphost.id

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-jumphost-eip"
    Type = "ElasticIP"
  })
}
