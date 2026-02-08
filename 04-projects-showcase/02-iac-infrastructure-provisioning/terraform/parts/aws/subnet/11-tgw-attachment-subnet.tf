# 11. Transit Gateway Attachment Subnet
# Highly recommended to use dedicated small subnets (/28) per AZ for TGW attachments.

resource "aws_subnet" "tgw_attachment" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.254.0/28"
  availability_zone = "us-east-1a"

  tags = {
    Name = "TGW-Attachment-Subnet"
    Tier = "Transit"
  }
}
