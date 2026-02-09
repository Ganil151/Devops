# 17. VPN Access Security Group
# Allows traffic from on-premises CIDR ranges.

resource "aws_security_group" "vpn_access" {
  name        = "vpn-access-sg"
  description = "Allows traffic from corporate VPN"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.0.0/16"] # Example Home/VPN range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPN-Access-SG"
  }
}
