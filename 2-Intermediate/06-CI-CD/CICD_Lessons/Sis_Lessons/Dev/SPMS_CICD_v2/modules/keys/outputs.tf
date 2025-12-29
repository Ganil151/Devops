output "key_name" {
  description = "The name of the generated key_pair"
  value       = aws_key_pair.sis_key.key_name
}
