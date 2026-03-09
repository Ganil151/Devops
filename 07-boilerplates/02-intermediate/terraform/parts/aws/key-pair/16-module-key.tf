# 16. Key Pair Module
# Reusable module for key pair creation.

module "app_key" {
  source = "./modules/key-pair"

  key_name    = "app-server-key"
  environment = "production"
  team        = "platform"
}

# Module definition (modules/key-pair/main.tf):
# variable "key_name" {}
# variable "environment" {}
# variable "team" {}
#
# resource "tls_private_key" "this" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }
#
# resource "aws_key_pair" "this" {
#   key_name   = var.key_name
#   public_key = tls_private_key.this.public_key_openssh
#   tags = {
#     Environment = var.environment
#     Team        = var.team
#   }
# }
