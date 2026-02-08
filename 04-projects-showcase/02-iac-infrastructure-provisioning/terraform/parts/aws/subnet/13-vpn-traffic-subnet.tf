# 13. VPN Subnet
# For traffic originating from or going to on-premises data centers via Site-to-Site VPN.

resource "aws_subnet" "vpn_tier" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "VPN-Traffic-Subnet"
    Tier = "Hybrid"
  }
}
