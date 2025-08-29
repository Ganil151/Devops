project_name = "terra-app"

# Vpc
vpc_id            = "terra_vpc"
vpc_cidr_block    = "10.0.0.0/16"
subnet_cidr_block = "10.0.0.0/24"

public_subnet_cidrs = ["10.0.1.0/24"]

private_subnet_cidrs = [ "10.0.10.0/24"]

enable_dns_support      = true
enable_dns_hostnames    = true
map_public_ip_on_launch = true


# # Security Group
security_group_ids = [""]

# # Keys
key_name = "terra-keys"

# # Ec2
ami                         = "ami-00ca32bbc84273381" # Aws Linux 2023
instance_type               = "t3.small"
subnet_id                   = "terra_subnet"
user_data                   = ""
user_data_replace_on_change = true
