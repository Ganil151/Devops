# 14. Outpost Subnet
# Subnet deployed on physical AWS Outposts in your own data center.

resource "aws_subnet" "outpost" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.90.0/24"
  outpost_arn       = "arn:aws:outposts:us-east-1:123456789012:outpost/op-01234567890abcdef"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Outpost-OnPrem-Subnet"
  }
}
