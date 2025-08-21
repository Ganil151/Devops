project_name = "jenkins-server"


# Vpc
vpc_id                  = "jenkins_vpc"
vpc_cidr_block          = "10.0.0.0/16"
subnet_cidr_block       = "10.0.0.0/24"
enable_dns_support      = true
enable_dns_hostnames    = true
map_public_ip_on_launch = true

# Security Group
security_group_id = ["jenkins-sg"]

# Keys
# key_name = "jenkins-keys"

# Ec2
# ami                         = "ami-020cba7c55df1f615"
# instance_type               = "t3.micro"
# subnet_id                   = "jenkins_subnet"
# user_data_replace_on_change = true
