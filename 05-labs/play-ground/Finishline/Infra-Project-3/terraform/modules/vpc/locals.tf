# =============================================================================
# VPC Module - Local Values
# Finish Line 2026 Infrastructure
# =============================================================================

locals {
  # Common tags applied to all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.manage_by
    Module      = "vpc"
  }

  # Project name with environment prefix for unique naming
  project_name = "${var.project_name}-${var.environment}"
}
