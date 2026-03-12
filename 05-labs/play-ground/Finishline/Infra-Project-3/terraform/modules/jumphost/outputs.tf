# =============================================================================
# Jumphost Module - Output Values
# Finish Line 2026 Infrastructure
# =============================================================================

output "jumphost_instance_id" {
  description = "Instance ID of the jumphost"
  value       = aws_instance.jumphost.id
}

output "jumphost_public_ip" {
  description = "Public IP address of the jumphost"
  value       = aws_eip.jumphost_eip.public_ip
}

output "jumphost_public_dns" {
  description = "Public DNS name of the jumphost"
  value       = aws_instance.jumphost.public_dns
}

output "jumphost_security_group_id" {
  description = "Security group ID of the jumphost"
  value       = aws_security_group.jumphost_sg.id
}

output "ssh_command" {
  description = "SSH command to connect to jumphost"
  value       = "ssh -i <key-file> ec2-user@${aws_eip.jumphost_eip.public_ip}"
}
