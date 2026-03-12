# =============================================================================
# Key Pair Module - Output Values
# Finish Line 2026 Infrastructure
# =============================================================================

output "key_name" {
  description = "Name of the SSH key pair"
  value       = aws_key_pair.finishline_key.key_name
}

output "key_pair_id" {
  description = "EC2 Key Pair ID"
  value       = aws_key_pair.finishline_key.id
}

output "private_key_filename" {
  description = "Local path to the private key file"
  value       = local_file.private_key.filename
}
