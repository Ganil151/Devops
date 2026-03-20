#============================================================
#  Security Group Outputs
#============================================================
output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.finishline_sg.id
}

output "security_group_name" {
  description = "Name of the security group"
  value       = aws_security_group.finishline_sg.name
}

output "security_group_arn" {
  description = "ARN of the security group"
  value       = aws_security_group.finishline_sg.arn
}
