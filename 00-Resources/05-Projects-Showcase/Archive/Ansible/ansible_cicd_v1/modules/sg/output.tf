# app/modules/sg/output.tf
output "cicd_sg" {
  value = aws_security_group.cicd_sg.id
}

