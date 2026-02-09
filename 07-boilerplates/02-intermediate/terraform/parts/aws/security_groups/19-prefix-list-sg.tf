# 19. Prefix List Security Group
# Using customer-managed prefix lists for IP management.

resource "aws_security_group" "prefix_list_sg" {
  name        = "prefix-list-sg"
  description = "Uses Managed Prefix Lists for ingress"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [aws_ec2_managed_prefix_list.trusted.id]
  }

  tags = {
    Name = "Prefix-List-Managed-SG"
  }
}

resource "aws_ec2_managed_prefix_list" "trusted" {
  name           = "Trusted-IP-Ranges"
  address_family = "IPv4"
  max_entries    = 5

  entry {
    cidr        = "203.0.113.0/24"
    description = "HQ"
  }
}
