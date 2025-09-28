# spms-app2\terraform.tfvars
aws_region                  = "us-east-1"
project_name                = "jenkins-app"
ami_name_pattern            = "amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"
ami_virtualization_type     = "hvm"
key_name                    = "spms_key"
instance_type               = "t3.small"
security_group_id           = ["jenkins-sg"]
subnet_id                   = "spms_subnet"
user_data                   = ""
vpc_id                      = "spms_vpc"
vpc_cidr_block              = "10.0.0.0/16"
subnet_cidr_block           = "10.0.0.0/24"
enable_dns_support          = true
enable_dns_hostnames        = true
map_public_ip_on_launch     = true
user_data_replace_on_change = true
# VPC Module Variables
vpc_name          = "spms-vpc"
vpc_cidr          = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.101.0/24", "10.0.102.0/24"]
enable_nat_gateway = true
enable_vpn_gateway = false

