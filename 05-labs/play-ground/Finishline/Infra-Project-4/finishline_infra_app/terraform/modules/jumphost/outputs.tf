#=============================================================
# Jumphost Outputs
#=============================================================

output "jumphost_id" {
  description = "The ID of the jumphost instance"
  value       = aws_instance.jumphost.id
}

output "jumphost_public_ip" {
  description = "The public IP address of the jumphost instance"
  value       = aws_instance.jumphost.public_ip
}

output "jumphost_private_ip" {
  description = "The private IP address of the jumphost instance"
  value       = aws_instance.jumphost.private_ip
}

output "jumphost_security_group_id" {
  description = "The ID of the jumphost security group"
  value       = aws_security_group.jumphost-sg.id
}

#=============================================================
# Security Group Outputs
#=============================================================

output "jumphost_security_group_name" {
  description = "The name of the jumphost security group"
  value       = aws_security_group.jumphost-sg.name
}

output "jumphost_security_group_description" {
  description = "The description of the jumphost security group"
  value       = aws_security_group.jumphost-sg.description
}

#=============================================================
# IAM Role Outputs
#=============================================================

output "jumphost_role_name" {
  description = "The name of the jumphost IAM role"
  value       = aws_iam_role.jumphost_role.name
}

output "jumphost_role_arn" {
  description = "The ARN of the jumphost IAM role"
  value       = aws_iam_role.jumphost_role.arn
}

#=============================================================
# Connection Info Outputs
#=============================================================
output "jumphost_connection_info" {
  description = "Connection information for the jumphost instance"
  value       = {
    host = aws_instance.jumphost.public_ip  
    username = "ec2-user"
    key_file = var.key_pair_name
    public_ip  = aws_instance.jumphost.public_ip
    private_ip = aws_instance.jumphost.private_ip
    instance_id = aws_instance.jumphost.id
  }
  sensitive = true
}
