output "key_name" {
  description = "The name of the created AWS key pair"
  value       = aws_key_pair.key_pair.key_name
}

output "public_key" {
  description = "The public key of the AWS key pair"
  value       = tls_private_key.rsa_4096.public_key_openssh
}

output "private_key_pem" {
  description = "The private key in PEM format"
  value       = tls_private_key.rsa_4096.private_key_pem
  sensitive   = true
}

output "private_key_filename" {
  description = "The filename where the private key is stored locally"
  value       = local_file.private_key.filename
}
