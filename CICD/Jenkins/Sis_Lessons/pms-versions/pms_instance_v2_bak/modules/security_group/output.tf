output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.petclinic_sg.id
}

output "security_group_name" {
  description = "The name of the security group"
  value       = aws_security_group.petclinic_sg.name
}

output "vpc_id" {
  description = "The VPC ID associated with the security group"
  value       = aws_security_group.petclinic_sg.vpc_id
}
