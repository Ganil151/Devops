output "jenkins_sg_id" {
  description = "ID of the Jenkins security group"
  value       = aws_security_group.jenkins.id
}

output "sonarqube_sg_id" {
  description = "ID of the SonarQube security group"
  value       = aws_security_group.sonarqube.id
}