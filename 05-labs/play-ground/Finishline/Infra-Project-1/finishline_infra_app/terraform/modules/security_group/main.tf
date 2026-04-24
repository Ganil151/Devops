# =============================================================================
# Security Group Module
# Module: security_group
# Assignment Reference: Finish Line 2026 §69, §70, §73 (SSH restriction to home IP CIDRs)
# =============================================================================

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------

locals {
  # Determine security group name
  security_group_name = var.security_group_name != "" ? var.security_group_name : "${var.project_name}-${var.environment}-sg"

  # Determine security group description
  security_group_description = var.security_group_description != "" ? var.security_group_description : "Security group for ${var.project_name} in ${var.environment} environment"

  # Merge default tags with additional tags
  tags = merge({
    Name        = local.security_group_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.manage_by
  }, var.additional_tags)

  # Transform ingress rules to match Terraform's expected format
  ingress_rules_transformed = [
    for rule in var.ingress_rules : {
      description = rule.description
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      cidr_blocks = split(",", rule.cidr_blocks)
    }
  ]

  # Transform egress rules (if provided, otherwise use default allow all)
  egress_rules_transformed = length(var.egress_rules) > 0 ? [
    for rule in var.egress_rules : {
      description = rule.description
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      cidr_blocks = split(",", rule.cidr_blocks)
    }
  ] : [{
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

# =============================================================================
# Security Group Resource
# =============================================================================

resource "aws_security_group" "finishline_sg" {
  name        = local.security_group_name
  description = local.security_group_description
  vpc_id      = var.vpc_id

  # Dynamic ingress rules
  dynamic "ingress" {
    for_each = local.ingress_rules_transformed
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # Dynamic egress rules
  dynamic "egress" {
    for_each = local.egress_rules_transformed
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port   = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = local.tags

  # Lifecycle configuration
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [ingress, egress]
  }
}
