#==========================================================
# Security Group Outputs
#==========================================================

output "security_group_id" {
  value = aws_security_group.finishline-sg.id
}

output "security_group_arn" {
  value = aws_security_group.finishline-sg.arn
}

output "security_group_name" {
  value = aws_security_group.finishline-sg.name
}

#==========================================================
# Security Group VPC Outputs
#==========================================================
output "vpc_id" {
  value = aws_security_group.finishline-sg.vpc_id
}

#==========================================================
# Security Group Configurations
#==========================================================
output "description" {
  value = aws_security_group.finishline-sg.description
}

output "ingress_rules" {
  value = aws_security_group.finishline-sg.ingress
}

output "egress_rules" {
  value = aws_security_group.finishline-sg.egress
}