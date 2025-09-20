project_name_1 = "master-server"
project_name_2 = "worker-server"
project_name_3 = "ansible-server"
project_name_4 = "eks-server"

#Vpc
vpc_id                  = "sis_vpc"
vpc_cidr_block          = "10.0.0.0/16"
subnet_cidr_block       = "10.0.0.0/24"
public_subnet_cidrs     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs    = ["10.0.10.0/24", "10.0.11.0/24"]
enable_dns_support      = true
enable_dns_hostnames    = true
map_public_ip_on_launch = true

# Security Group
ingress_rules = [22, 80, 443, 3000, 8080, 8888, 8761, 9090, 9091, 9411]
egress_rules  = [0]

# Keys
key_name = "sis_keys"

# Ec2
ami                         = "ami-00ca32bbc84273381"
instance_type               = "t3.small"
subnet_id                   = "sis_subnet"
user_data                   = ""
user_data_replace_on_change = false
security_group_ids          = [""]
