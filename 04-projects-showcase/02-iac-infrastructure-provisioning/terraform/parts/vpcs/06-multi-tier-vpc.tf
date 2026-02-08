# 06. Multi-Tier VPC
# A design with public, private, and isolated tiers for layered security.

resource "aws_vpc" "multi_tier" {
  cidr_block = "10.10.0.0/16"
  
  tags = {
    Name = "Enterprise-Multi-Tier-VPC"
  }
}

# 1. Public Tier (DMZ)
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.multi_tier.id
  cidr_block = "10.10.1.0/24"
  tags       = { Name = "Public-Tier" }
}

# 2. Private Tier (App)
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.multi_tier.id
  cidr_block = "10.10.2.0/24"
  tags       = { Name = "Private-Tier" }
}

# 3. Isolated Tier (DB)
resource "aws_subnet" "isolated" {
  vpc_id     = aws_vpc.multi_tier.id
  cidr_block = "10.10.3.0/24"
  tags       = { Name = "Isolated-Tier" }
}
