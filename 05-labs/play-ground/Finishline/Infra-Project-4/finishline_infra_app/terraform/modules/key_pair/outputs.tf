#==========================================================
# Key Pair Outputs
#==========================================================

output "key_pair_id" {
  description = "The key pair ID"
  value       = aws_key_pair.finishline_public_key.id
}

output "key_pair_key_name" {
  description = "The key pair name"
  value       = aws_key_pair.finishline_public_key.key_name
}

output "private_key_path" {
  description = "The path where the private key is saved"
  value       = local_file.finishline_private_key.filename
}

output "private_key_pem" {
  description = "The private key content (for reference)"
  value       = tls_private_key.rsa_4096.private_key_pem
  sensitive   = true
}

output "public_key" {
  description = "The public key content"
  value       = tls_private_key.rsa_4096.public_key_pem
}
