locals {

  private_key_filename = var.computed_private_key_filename != "" ? var.computed_private_key_filename : (var.private_key_filename != "" ? var.private_key_filename : "${var.key_name}.pem")
  private_key_path =var.computed_private_key_path != "" ? var.computed_private_key_path : "${var.private_key_directory}/${local.private_key_filename}"
  
  tags = length(var.computed_tags) > 0 ? var.computed_tags : {
    Name        = var.key_name
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managed_by
    Module    = "/key_pair"
  }

}