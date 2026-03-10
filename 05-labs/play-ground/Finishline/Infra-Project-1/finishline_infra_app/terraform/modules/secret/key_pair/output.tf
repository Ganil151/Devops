# =============================================================================
# Key Pair Module Outputs
# Module: secret/key_pair
# Assignment Reference: Finish Line 2026 §71, §73 (Terraform-managed SSH keypairs)
# =============================================================================

# -----------------------------------------------------------------------------
# Key Pair Identity
# -----------------------------------------------------------------------------

output "key_name" {
  description = "The name of the EC2 key pair"
  value       = aws_key_pair.finishline_public_key.key_name
}

output "key_pair_id" {
  description = "The unique ID of the key pair"
  value       = aws_key_pair.finishline_public_key.id
}

output "key_pair_arn" {
  description = "The ARN of the EC2 key pair"
  value       = aws_key_pair.finishline_public_key.arn
}

# -----------------------------------------------------------------------------
# Key Fingerprints (for verification)
# -----------------------------------------------------------------------------

output "fingerprint" {
  description = "The SHA-1 digest of the public key (AWS fingerprint format)"
  value       = aws_key_pair.finishline_public_key.fingerprint
}

output "fingerprint_sha256" {
  description = "The SHA-256 digest of the public key"
  value       = aws_key_pair.finishline_public_key.fingerprint
}

# -----------------------------------------------------------------------------
# Public Key Materials
# -----------------------------------------------------------------------------

output "public_key_pem" {
  description = "The public key in PEM format"
  value       = tls_private_key.rsa_4096.public_key_pem
}

output "public_key_openssh" {
  description = "The public key in OpenSSH format (for authorized_keys)"
  value       = tls_private_key.rsa_4096.public_key_openssh
}

output "public_key_pem_encoded" {
  description = "The public key in PEM-encoded PKCS#8 format"
  value       = tls_private_key.rsa_4096.public_key_pem
}

# -----------------------------------------------------------------------------
# Private Key Materials (SENSITIVE)
# -----------------------------------------------------------------------------

output "private_key_pem" {
  description = "The private key in PEM format (SENSITIVE)"
  value       = tls_private_key.rsa_4096.private_key_pem
  sensitive   = true
}

output "private_key_openssh" {
  description = "The private key in OpenSSH format (SENSITIVE)"
  value       = tls_private_key.rsa_4096.private_key_openssh
  sensitive   = true
}

output "private_key_pem_pkcs8" {
  description = "The private key in PKCS#8 PEM format (SENSITIVE)"
  value       = tls_private_key.rsa_4096.private_key_pem_pkcs8
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Local File Information
# -----------------------------------------------------------------------------

output "private_key_file_path" {
  description = "The local file path where the private key is saved"
  value       = local_file.finishline_private_key.filename
}

# -----------------------------------------------------------------------------
# Key Properties
# -----------------------------------------------------------------------------

output "algorithm" {
  description = "The algorithm used for key generation (RSA)"
  value       = tls_private_key.rsa_4096.algorithm
}

output "rsa_bits" {
  description = "The number of bits in the RSA key (4096)"
  value       = tls_private_key.rsa_4096.rsa_bits
}

# -----------------------------------------------------------------------------
# Composite Outputs
# -----------------------------------------------------------------------------

output "ssh_connection_info" {
  description = "SSH connection information bundle (SENSITIVE)"
  value = {
    key_name        = aws_key_pair.finishline_public_key.key_name
    private_key_pem = sensitive(tls_private_key.rsa_4096.private_key_pem)
    public_key      = tls_private_key.rsa_4096.public_key_openssh
    file_path       = local_file.finishline_private_key.filename
  }
  sensitive = true
}

output "key_pair_details" {
  description = "Complete key pair details for documentation"
  value = {
    name            = aws_key_pair.finishline_public_key.key_name
    id              = aws_key_pair.finishline_public_key.id
    arn             = aws_key_pair.finishline_public_key.arn
    fingerprint     = aws_key_pair.finishline_public_key.fingerprint
    fingerprint_sha = aws_key_pair.finishline_public_key.fingerprint
    algorithm       = tls_private_key.rsa_4096.algorithm
    key_bits        = tls_private_key.rsa_4096.rsa_bits
    created_at      = timestamp()
  }
}
