#============================================================
#  Jumphost Module - Development Environment
#============================================================

include {
  path = find_in_parent_folders("root.hcl")
}

# Dependency on VPC module
dependency "vpc" {
  config_path = "../../networking/vpc"
}

# Dependency on Security Group module
dependency "sg" {
  config_path = "../../networking/sg"
}

# Dependency on Key Pair module
dependency "key_pair" {
  config_path = "../../security/key_pair"
}

# Dependency on IAM instance profile (optional)
dependency "iam" {
  config_path = "../../security/iam"
  mock_outputs = {
    jumphost_instance_profile_name = ""
  }
  skip_outputs = true
}

terraform {
  source = "../../../../modules//compute/jumphost"
}

#------------------------------------------------------------
#  Load Bootstrap Script (legacy - use use_install_tools_script instead)
#------------------------------------------------------------
locals {
  bootstrap_script_path = "${get_terragrunt_dir()}/../../../../bootstrap/scripts/jumphost_bootstrap.sh"
  bootstrap_script      = fileexists(local.bootstrap_script_path) ? file(local.bootstrap_script_path) : ""
}

inputs = {
  project_name = "finishline-infra-app"
  environment  = "dev"
  managed_by   = "finishline-infra-team"
  aws_region   = "us-east-1"

  # Jumphost Instance Configuration
  instance_name = "jumphost"

  is_jumphost_enabled = true

  # AMI Configuration (leave empty for latest Amazon Linux 2)
  ami_id = ""

  # Instance Type
  instance_type = "t3.micro"

  # Network Configuration
  subnet_id              = dependency.vpc.outputs.public_subnet_ids[0]
  security_group_ids     = [dependency.sg.outputs.security_group_id]
  key_pair_name          = dependency.key_pair.outputs.key_pair_name
  iam_instance_profile_name = try(dependency.iam.outputs.jumphost_instance_profile_name, "")

  # Public Access Configuration
  associate_public_ip_address = true
  allocate_eip                = false

  # Private IP (optional - leave empty for automatic assignment)
  private_ip = ""

  # Root Volume Configuration
  root_volume_type                  = "gp3"
  root_volume_size                  = 30
  root_volume_encrypted             = true
  root_volume_kms_key_id            = ""
  root_volume_delete_on_termination = true

  # Additional EBS Volumes (optional)
  ebs_block_devices = []

  # IMDSv2 Configuration (Security Best Practice)
  metadata_http_endpoint               = "enabled"
  metadata_http_tokens                 = "required"
  metadata_http_put_response_hop_limit = 1
  metadata_instance_metadata_tags      = "disabled"

  # Monitoring Configuration
  detailed_monitoring = false

  # CloudWatch Logs Configuration
  enable_cloudwatch_logs        = true
  cloudwatch_log_retention_days = 30

  # Install Tools Script - enables automatic tool installation on jumphost
  use_install_tools_script      = true
  install_tools_script_path     = "../../../scripts/jumphost-install-tools.sh"

  # Custom user_data (leave empty to use default install-tools script)
  user_data = ""

  user_data_replace_on_change = false

  auto_recovery = "default"

  computed_tags = {}

}
