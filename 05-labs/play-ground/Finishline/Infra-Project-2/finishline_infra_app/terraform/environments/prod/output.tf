# =============================================================================
# Outputs: prod Environment
# =============================================================================

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.finishline_vpc.vpc_id
}
