#========================================================
#  Security Group Outputs
#========================================================

output "finishline_sg_id" {
  description = "Security Group ID"
  value = aws_security_group.finishline_sg.id
}

output "ingress_rules" {
  description = "Ingress rules for the security group"
  value = aws_security_group.finishline_sg
}

output "egress_rules" {
  description = "Egress rules for the security group"
  value = aws_security_group.finishline_sg
}

output "security_group_description" {
  description = "The description for the security group"
  value = aws_security_group.finishline_sg.description
}