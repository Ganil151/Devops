# =============================================================================
# IAM Module - Output Values
# Finish Line 2026 Infrastructure
# =============================================================================

output "jumphost_role_name" {
  description = "Name of the jumphost IAM role"
  value       = aws_iam_role.jumphost_role.name
}

output "jumphost_role_arn" {
  description = "ARN of the jumphost IAM role"
  value       = aws_iam_role.jumphost_role.arn
}
