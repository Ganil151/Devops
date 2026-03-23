#============================================================
#  Jumphost EC2 Instance
#============================================================
resource "aws_instance" "jumphost" {
  count = var.is_jumphost_enabled ? 1 : 0

  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux[0].id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_pair_name
  iam_instance_profile   = var.iam_instance_profile_name

  # Root block device
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    encrypted             = var.root_volume_encrypted
    kms_key_id            = var.root_volume_kms_key_id
    delete_on_termination = var.root_volume_delete_on_termination
    tags = merge(local.tags, {
      Name = "${local.instance_name}-root"
    })
  }

  # Additional EBS volumes
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      device_name           = ebs_block_device.value.device_name
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp3")
      volume_size           = lookup(ebs_block_device.value, "volume_size", 100)
      encrypted             = lookup(ebs_block_device.value, "encrypted", true)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", false)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
    }
  }

  # Network configuration
  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = var.private_ip != "" ? var.private_ip : null

  # Metadata options (IMDSv2)
  metadata_options {
    http_endpoint               = var.metadata_http_endpoint
    http_tokens                 = var.metadata_http_tokens
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_instance_metadata_tags
  }

  # Monitoring
  monitoring = var.detailed_monitoring

  # User data - use the install-tools script if enabled and no custom user_data provided
  # Note: user_data accepts plain text up to 16KB; AWS automatically base64 encodes it
  user_data                   = var.use_install_tools_script && var.user_data == "" ? (var.install_tools_script_path != "" ? file(var.install_tools_script_path) : null) : (var.user_data != "" ? var.user_data : null)
  user_data_replace_on_change = var.user_data_replace_on_change

  # Maintenance options
  maintenance_options {
    auto_recovery = var.auto_recovery
  }

  tags = local.tags
}

#============================================================
#  Jumphost Elastic IP (Optional)
#============================================================
resource "aws_eip" "jumphost" {
  count = var.is_jumphost_enabled && var.allocate_eip ? 1 : 0

  instance = aws_instance.jumphost[0].id
  domain   = "vpc"

  tags = merge(local.tags, {
    Name = "${local.instance_name}-eip"
  })

  depends_on = [aws_instance.jumphost]
}

#============================================================
#  CloudWatch Log Group for Jumphost
#============================================================
resource "aws_cloudwatch_log_group" "jumphost" {
  count = var.is_jumphost_enabled && var.enable_cloudwatch_logs ? 1 : 0

  name              = "/aws/ec2/${local.instance_name}"
  retention_in_days = var.cloudwatch_log_retention_days

  tags = local.tags
}
