#============================================================
#  Key Pair Outputs
#============================================================

output "key_pair_name" {
  description = "Name of the created key pair"
  value       = aws_key_pair.finishline_public_key.key_name
}

output "key_pair_arn" {
  description = "ARN of the created key pair"
  value       = aws_key_pair.finishline_public_key.arn
}

output "public_key" {
  description = "Public key in OpenSSH format"
  value       = aws_key_pair.finishline_public_key.public_key
}

output "public_key_openssh" {
  description = "Public key in OpenSSH format"
  value       = tls_private_key.rsa_4096.public_key_openssh
}

output "private_key_pem" {
  description = "Private key in PEM format (sensitive)"
  value       = tls_private_key.rsa_4096.private_key_pem
  sensitive   = true
}

output "private_key_path" {
  description = "Path to the saved private key file"
  value       = local.private_key_path
}
