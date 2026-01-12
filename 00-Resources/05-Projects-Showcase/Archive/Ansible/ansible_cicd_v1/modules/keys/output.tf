output "key_name" {
  value = aws_key_pair.cicd_key.key_name
  sensitive = true
}