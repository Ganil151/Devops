# =============================================================================
# Data Source: Amazon Linux 2023 AMI
# Reference: https://docs.aws.amazon.com/linux/al2023/ug/what-is-amazon-linux.html
# =============================================================================
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
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

# =============================================================================
# Jumphost EC2 Instance
# Assignment Requirement: Amazon Linux 2023 with SSH restricted to home IP CIDRs
# Reference: Assignment PDF §69, §70, §73
# =============================================================================
resource "aws_instance" "jump_host" {
  # AMI Selection: Use provided AMI ID or default to Amazon Linux 2023 x86_64
  ami                  = var.ami_id == "" ? data.aws_ami.amazon_linux_2023.id : var.ami_id
  instance_type        = var.instance_type
  subnet_id            = var.public_subnet_ids[0]
  iam_instance_profile = var.iam_instance_profile_name
  key_name             = var.key_name
  availability_zone    = var.availability_zone

  # Root Volume: Encrypted gp3 with specified size
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
    iops                  = var.root_volume_iops
  }

  # User Data: Base64-encoded script for tool installation
  # Tools: aws-cli v2, kubectl, helm, kustomize, mysql-client
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = true

  # Metadata Options: IMDSv2 required for security hardening
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = merge({
    Name        = "${var.project_name}-${var.environment}-jump-host"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.manage_by
  }, var.additional_tags)
}
