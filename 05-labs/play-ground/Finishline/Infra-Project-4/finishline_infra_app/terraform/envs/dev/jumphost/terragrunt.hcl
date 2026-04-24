#============================================================
#  Jumphost Module - Development Environment
#============================================================

include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules//jumphost"
}

inputs = {
  project_name    = "finishline-infra"
  environment     = "development"
  manage_by      = true
  availability_zone = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # VPC Configuration
  vpc_id              = dependency.vpc.outputs.vpc_id
  jumphost_subnet_id  = dependency.vpc.outputs.public_subnet_ids[0]

  # Jumphost Configuration
  jumphost_instance_type       = "t3.micro"
  jumphost_security_group_name = "finishline-jumphost-sg"
  key_pair_name               = dependency.vpc.outputs.key_pair_key_name

  # Root Block Device
  root_block_device = {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true
  }
}

dependency "vpc" {
  config_path   = "../vpc"
  skip_outputs  = false

  mock_outputs = {
    vpc_id             = "vpc-0abc123def456789a"
    public_subnet_ids  = ["subnet-0abc123def456789a"]
    key_pair_key_name  = "mock-key-pair"
  }
}

dependencies {
  paths = ["../vpc"]
}
