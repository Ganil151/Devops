#============================================================
#  Terragrunt Root Configuration
#============================================================

remote_state {
  backend = "s3"
  config = {
    bucket = "finishline-infra-app-ba3347ce"
    key = "${path_relative_to_include()}/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
  }
  generate = {
    path = "backend.tf"
    if_exists = "overwrite"
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "finishline-infra"
      Environment = "development"
      ManagedBy   = "finishline-infra-team"
      Terraform   = "true"
    }
  }
}
EOF
}

inputs = {
  aws_region = "us-east-1"
}