# 08. Web Tier Subnet
# Public subnet for front-facing web servers or reverse proxies.

resource "aws_subnet" "web_tier" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Web-Tier-Subnet"
    Tier = "Web"
  }
}
