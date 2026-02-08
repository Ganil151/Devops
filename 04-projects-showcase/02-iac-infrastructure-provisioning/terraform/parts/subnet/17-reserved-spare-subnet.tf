# 17. Reserved Spare Subnet
# CIDR space reserved for future growth or migration.

resource "aws_subnet" "spare" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.200.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "Reserved-Spare-Subnet"
    Status = "Placeholder"
  }
}
