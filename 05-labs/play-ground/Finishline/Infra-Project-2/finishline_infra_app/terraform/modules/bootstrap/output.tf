#========================================================
#  Bootstrap Module Outputs
#========================================================

output "jumphost_id" {
  description = "Jumphost instance ID"
  value       = aws_instance.jumphost.id
}

output "jumphost_public_ip" {
  description = "Jumphost public IP address"
  value       = aws_instance.jumphost.public_ip
}

output "jumphost_private_ip" {
  description = "Jumphost private IP address"
  value       = aws_instance.jumphost.private_ip
}

output "jumphost_arn" {
  description = "Jumphost instance ARN"
  value       = aws_instance.jumphost.arn
}
