# 05. Multi-AZ Subnet Pair
# Demonstrating how to use count to create subnets across multiple AZs.

variable "az_names" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

resource "aws_subnet" "multi_az" {
  count             = length(var.az_names)
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.${count.index + 20}.0/24"
  availability_zone = var.az_names[count.index]

  tags = {
    Name = "Subnet-${var.az_names[count.index]}"
  }
}
