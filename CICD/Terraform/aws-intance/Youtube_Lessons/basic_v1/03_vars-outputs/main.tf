terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
  }
}


locals {
  environment = "prod"
  upper_case  = upper(local.environment)
  base_path   = "${path.module}/configs/${local.upper_case}"
}

resource "local_file" "server_configs" {
  filename = "${local.base_path}/server1.sh"
  content  = <<EOT
  environment = ${local.environment}
  port=3000
  EOT
}

resource "local_file" "server_configs_2" {
  filename = "${local.base_path}/server2.sh"
  content  = <<EOT
  environment = ${local.environment}
  port=3000
  EOT
}

resource "local_file" "server_configs_3" {
  filename = "${local.base_path}/server3.sh"
  content  = <<EOT
  environment = ${local.environment}
  port=3000
  EOT
}

# Outputs
output "filename_1" {
  value = local_file.server_configs.filename
}


















# resource "local_file" "example1" {
#   filename = "${path.module}/${var.filename-1}.txt"
#   content  = "this is demo content - 1"
#   count    = var.count_num
# }

# locals {
#   base_path = "${path.module}/files"
# }

# resource "local_file" "example2" {
#   filename = "${local.base_path}/example2.md"
#   content  = "this is demo content - 2"
# }

# resource "local_file" "example3" {
#   filename = "${local.base_path}/example3.md"
#   content  = "this is demo content - 3"
# }

# resource "local_file" "example4" {
#   filename = "${local.base_path}/example4. md"
#   content  = "this is demo content - 4"
# }

