# Networking Boilerplate: Standard 3-Tier VPC (Terraform)

/* 
   This template provides a production-ready VPC structure with 
   Private, Public, and Database isolates.
*/

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "devops-production-vpc"
  cidr = "10.0.0.0/16"

  # Availability Zones
  azs             = ["us-east-1a", "us-east-1b"]
  
  # Subnet Layout
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets = ["10.0.201.0/24", "10.0.202.0/24"]

  # Gateway Configuration
  enable_nat_gateway = true
  single_nat_gateway = true # Cost optimization for non-prod
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "prod"
    Project     = "Infrastructure-Core"
  }
}

---

# Troubleshooting Guide: Why can't I ping?

1. **VPC Level**: Is the 'Enable DNS Hostnames' set to true?
2. **Subnet Level**: Is there a route to a NAT Gateway (for Private) or IGW (for Public)?
3. **Instance Level**: Does the Security Group allow ICMP (Ping) traffic?
4. **Network Level**: Is there an OS-level firewall (iptables/ufw) blocking the port?
