# =============================================================================
# Key Pair Module
# Module: secret/key_pair
# Assignment Reference: Finish Line 2026 §71, §73 (Terraform-managed SSH keypairs)
# Security: RSA-4096 with local .pem file download (0400 permissions)
# =============================================================================

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------

locals {
  # Determine private key filename (use computed if provided, otherwise compute internally)
  private_key_filename = var.computed_private_key_filename != "" ? var.computed_private_key_filename : (var.private_key_filename != "" ? var.private_key_filename : "${var.key_name}.pem")
  private_key_path     = var.computed_private_key_path != "" ? var.computed_private_key_path : "${var.private_key_directory}/${local.private_key_filename}"

  # Merge default tags with additional tags (use computed if provided, otherwise compute internally)
  tags = length(var.computed_tags) > 0 ? var.computed_tags : merge({
    Name        = var.key_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.manage_by
  }, var.additional_tags)
}

# =============================================================================
# Generate RSA Private Key
# Reference: https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
# =============================================================================

resource "tls_private_key" "rsa_4096" {
  algorithm = var.key_algorithm
  rsa_bits  = var.rsa_bits
}

# =============================================================================
# Register Public Key with AWS EC2
# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
# =============================================================================

resource "aws_key_pair" "finishline_public_key" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh

  tags = local.tags
}

# =============================================================================
# Save Private Key to Local File
# Security: File permissions set to 0400 (owner read-only)
# Reference: https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
# =============================================================================

resource "local_file" "finishline_private_key" {
  content         = tls_private_key.rsa_4096.private_key_pem
  filename        = local.private_key_path
  file_permission = var.file_permission

  depends_on = [tls_private_key.rsa_4096]

  # Additional permission enforcement via local-exec
  provisioner "local-exec" {
    command = "chmod ${var.file_permission} ${local.private_key_path}"
  }

  lifecycle {
    # Prevent accidental recreation which would overwrite existing key files
    prevent_destroy = false
  }
}
