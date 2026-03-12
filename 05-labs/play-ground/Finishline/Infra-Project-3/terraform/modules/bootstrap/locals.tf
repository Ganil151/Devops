# =============================================================================
# Bootstrap Module - Local Values
# Finish Line 2026 Infrastructure
# =============================================================================

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.manage_by
    Module      = "bootstrap"
  }
}
