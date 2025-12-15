output "build_server_public_ip" {
  description = "Public IP of the build server"
  value       = module.build_server.public_ip
}

output "sonarqube_server_public_ip" {
  description = "Public IP of the SonarQube server"
  value       = module.sonarqube_server.public_ip
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${module.build_server.public_ip}:8080"
}

output "sonarqube_url" {
  description = "SonarQube URL"
  value       = "http://${module.sonarqube_server.public_ip}:9000"
}

output "ssh_private_key_path" {
  description = "Path to the SSH private key file"
  value       = module.key_pair.private_key_path
}

output "ssh_command_examples" {
  description = "Example SSH commands to connect to servers"
  value = {
    build_server     = "ssh -i ${module.key_pair.private_key_path} ubuntu@${module.build_server.public_ip}"
    jenkins_master   = "ssh -i ${module.key_pair.private_key_path} ubuntu@${module.jenkins_master.public_ip}"
    sonarqube_server = "ssh -i ${module.key_pair.private_key_path} ubuntu@${module.sonarqube_server.public_ip}"
  }
}