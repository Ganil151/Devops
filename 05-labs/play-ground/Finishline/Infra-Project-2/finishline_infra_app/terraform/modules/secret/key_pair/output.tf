#========================================================
#  Key Pair Outputs
#========================================================
output "key_name" {
  description = "Name of key pair"
  value       = var.key_name
}

output "private_key_filename" {
  description = "Private key filename"
  value       = local.key_pair_private_key_filename
}

output "private_key_pathname" {
  description = "Private key full path"
  value       = local.key_pair_private_key_pathname
}

output "public_key" {
  description = "Public key content"
  value       = tls_private_key.rsa_4096.public_key_openssh
}
