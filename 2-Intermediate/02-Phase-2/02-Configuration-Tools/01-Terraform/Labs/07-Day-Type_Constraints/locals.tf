locals {
  common_tags = {
    Project     = "Terraform-Gsmash-Demo"
    Environment = var.environment
    ManageBy    = "Terraform"
    LOB         = "Engineering"
    Stage       = "Alpha"
    CreateDate  = formatdate("YYYY-MM-DD", timestamp())
  }

  vpc_cidr    = element(var.network_config, 0)
  subnet_cidr = "${element(var.network_config, 1)}/${element(var.network_config, 2)}"

  # Instance configuration
  instance_name = "gsmash-${var.environment}-instance"


  # Security Group ports as map
  port_descriptions = {
    22  = "SSH Access"
    80  = "HTTP Access"
    443 = "HTTPS Access"
  }
}