# 07. App Tier Subnet
# Private subnet where application logic/servers reside.

resource "aws_subnet" "app_tier" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "App-Tier-Subnet"
    Tier = "App"
  }
}
