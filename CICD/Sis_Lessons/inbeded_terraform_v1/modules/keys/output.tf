output "key_name" {
  description = "The name of the generated key pair"
  value       = aws_key_pair.jenkins_key
}
