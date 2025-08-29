output "spms_master_sg_id" {
  value = aws_security_group.spms_sg.id
}

output "spms_wk_sg" {
  value = aws_security_group.spms_wk_sg.id
}
