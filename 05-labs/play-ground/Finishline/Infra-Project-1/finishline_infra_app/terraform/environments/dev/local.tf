# =============================================================================
# Local Values: dev Environment
# Project: Finish Line 2026 Infrastructure
# Assignment Reference: Finish Line 2026 §2, §21 (Target: us-east-1)
# Reporter: Joseph Ndzoh Dong
# Timeline: Feb 26, 2026 – March 2, 2026
# =============================================================================

locals {
  # Jumphost user data script (base64 encoded)
  # Reads from: terraform/scripts/jumphost-userdata.sh
  # Installs: aws-cli v2, kubectl, helm, kustomize, mysql-client, jq, git
  jumphost_user_data = coalesce(
    var.jumphost_user_data_base64,
    base64encode(file("${path.root}/../../scripts/jumphost-userdata.sh"))
  )

  # Key Pair Module Local Values
  # Determine private key filename
  key_pair_private_key_filename = var.private_key_filename != "" ? var.private_key_filename : "${var.key_name}.pem"
  key_pair_private_key_path     = "${var.private_key_directory}/${local.key_pair_private_key_filename}"

  # Merge default tags with additional tags for key pair
  key_pair_tags = merge({
    Name        = var.key_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.manage_by
  }, var.additional_tags)
}
