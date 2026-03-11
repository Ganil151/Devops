locals {
  key_pair_private_key_filename = var.private_key_filename != "" ? var.private_key_filename : "${var.key_name}.pem"
  key_pair_private_key_pathname = "${var.private_key_directory}/${local.key_pair_private_key_filename}"

  tags = length(var.computed_tags) > 0 ? var.computed_tags : merge({
    Name        = var.key_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managedBy
  }, var.additional_tags)
}
