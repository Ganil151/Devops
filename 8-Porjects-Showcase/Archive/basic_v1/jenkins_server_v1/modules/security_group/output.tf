output "jenkins_master_sg_id" {
  value = aws_security_group.jenkins_sg.id
}

output "jenkins_wk_sg" {
  value = aws_security_group.jenkins_wk_sg.id
}
