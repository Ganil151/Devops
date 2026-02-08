resource "aws_vpc" "primary_vpc" {
  cidr_block = var.primary_vpc_cidr
  provider = aws.primary
  instance_tenancy ="default"

  tags = {
    Name = "main"
  }
}