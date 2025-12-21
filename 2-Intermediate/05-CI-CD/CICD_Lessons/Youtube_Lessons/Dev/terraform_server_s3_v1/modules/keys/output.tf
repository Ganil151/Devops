output "key_name" {
  description = "The name of the generated key_pair"
  value       = aws_key_pair.terra_key.key_name
}