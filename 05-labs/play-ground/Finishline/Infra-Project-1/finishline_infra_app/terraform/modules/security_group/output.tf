# =============================================================================
# Security Group Module Outputs
# Module: security_group
# Assignment Reference: Finish Line 2026 §69, §70, §73 (SSH restriction)
# =============================================================================

# -----------------------------------------------------------------------------
# Core Security Group Identity
# -----------------------------------------------------------------------------

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.finishline_sg.id
}

output "security_group_arn" {
  description = "The ARN of the security group"
  value       = aws_security_group.finishline_sg.arn
}

output "security_group_name" {
  description = "The name of the security group"
  value       = aws_security_group.finishline_sg.name
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

output "vpc_id" {
  description = "The VPC ID where the security group is created"
  value       = aws_security_group.finishline_sg.vpc_id
}

# -----------------------------------------------------------------------------
# Security Group Configuration
# -----------------------------------------------------------------------------

output "description" {
  description = "The description of the security group"
  value       = aws_security_group.finishline_sg.description
}

output "ingress" {
  description = "The ingress rules configured on the security group"
  value       = aws_security_group.finishline_sg.ingress
}

output "egress" {
  description = "The egress rules configured on the security group"
  value       = aws_security_group.finishline_sg.egress
}

# -----------------------------------------------------------------------------
# Ownership & Metadata
# -----------------------------------------------------------------------------

output "owner_id" {
  description = "The AWS account ID of the security group owner"
  value       = aws_security_group.finishline_sg.owner_id
}

output "name_prefix" {
  description = "The name prefix of the security group"
  value       = aws_security_group.finishline_sg.name_prefix
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

output "tags" {
  description = "The tags applied to the security group (user-defined only)"
  value       = aws_security_group.finishline_sg.tags
}

output "tags_all" {
  description = "All tags applied to the security group (including provider defaults)"
  value       = aws_security_group.finishline_sg.tags_all
}

# -----------------------------------------------------------------------------
# Composite Outputs (for use in other modules)
# -----------------------------------------------------------------------------

output "security_group" {
  description = "Complete security group object for advanced use cases"
  value       = aws_security_group.finishline_sg
}

output "connection_info" {
  description = "Connection information for resources using this security group"
  value = {
    security_group_id = aws_security_group.finishline_sg.id
    vpc_id            = aws_security_group.finishline_sg.vpc_id
    ingress_rules     = aws_security_group.finishline_sg.ingress
    egress_rules      = aws_security_group.finishline_sg.egress
  }
}
