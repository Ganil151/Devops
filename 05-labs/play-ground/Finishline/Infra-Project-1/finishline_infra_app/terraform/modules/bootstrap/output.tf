# =============================================================================
# Jumphost EC2 Instance Outputs
# Module: bootstrap (Jumphost Provisioning)
# Assignment Reference: Finish Line 2026 §69, §70, §73, §83, §84, §87, §89
# =============================================================================

# -----------------------------------------------------------------------------
# Instance Identity
# -----------------------------------------------------------------------------

output "instance_id" {
  description = "The EC2 instance ID of the jumphost"
  value       = aws_instance.jump_host.id
}

output "instance_arn" {
  description = "The ARN of the jumphost EC2 instance"
  value       = aws_instance.jump_host.arn
}

output "public_ip" {
  description = "The public IP address of the jumphost (for SSH access)"
  value       = aws_instance.jump_host.public_ip
}

output "private_ip" {
  description = "The private IP address of the jumphost (for VPC-internal access)"
  value       = aws_instance.jump_host.private_ip
}

output "public_dns" {
  description = "The public DNS name of the jumphost"
  value       = aws_instance.jump_host.public_dns
}

output "private_dns" {
  description = "The private DNS name of the jumphost"
  value       = aws_instance.jump_host.private_dns
}

# -----------------------------------------------------------------------------
# Instance Configuration
# -----------------------------------------------------------------------------

output "availability_zone" {
  description = "The availability zone where the jumphost is deployed"
  value       = aws_instance.jump_host.availability_zone
}

output "subnet_id" {
  description = "The subnet ID where the jumphost is deployed"
  value       = aws_instance.jump_host.subnet_id
}

output "ami_id" {
  description = "The AMI ID used for the jumphost instance"
  value       = aws_instance.jump_host.ami
}

output "instance_type" {
  description = "The EC2 instance type of the jumphost"
  value       = aws_instance.jump_host.instance_type
}

output "key_name" {
  description = "The name of the key pair used for SSH access"
  value       = aws_instance.jump_host.key_name
}

# -----------------------------------------------------------------------------
# IAM & Security
# -----------------------------------------------------------------------------

output "iam_instance_profile" {
  description = "The IAM instance profile associated with the jumphost"
  value       = aws_instance.jump_host.iam_instance_profile
}

output "security_groups" {
  description = "List of security group IDs associated with the jumphost"
  value       = aws_instance.jump_host.security_groups
}

output "primary_network_interface_id" {
  description = "The ID of the primary network interface of the jumphost"
  value       = aws_instance.jump_host.primary_network_interface_id
}

# -----------------------------------------------------------------------------
# Storage
# -----------------------------------------------------------------------------

output "root_block_device_id" {
  description = "The ID of the root EBS volume"
  value       = try(aws_instance.jump_host.root_block_device[0].volume_id, null)
}

# -----------------------------------------------------------------------------
# Connection Information (for provisioners and SSH)
# -----------------------------------------------------------------------------

output "connection_ssh" {
  description = "Connection block for use with remote-exec provisioners or null_resource triggers"
  value = {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_instance.jump_host.public_ip
    private_key = sensitive(null) # Provide via variable or data source
  }
  sensitive = true
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

output "tags_all" {
  description = "All tags applied to the jumphost instance (including provider defaults)"
  value       = aws_instance.jump_host.tags_all
}
