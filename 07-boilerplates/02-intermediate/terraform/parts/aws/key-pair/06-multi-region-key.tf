# 6. Multi-Region Key Pair
# Deploy same key across multiple regions.

resource "tls_private_key" "multi_region" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "us_east" {
  provider   = aws.us_east_1
  key_name   = "multi-region-key"
  public_key = tls_private_key.multi_region.public_key_openssh

  tags = {
    Name   = "Multi-Region-Key-US-East"
    Region = "us-east-1"
  }
}

resource "aws_key_pair" "eu_west" {
  provider   = aws.eu_west_1
  key_name   = "multi-region-key"
  public_key = tls_private_key.multi_region.public_key_openssh

  tags = {
    Name   = "Multi-Region-Key-EU-West"
    Region = "eu-west-1"
  }
}
