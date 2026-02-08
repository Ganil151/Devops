# 07. VPN Route Table
# Route traffic to on-premises network via VPN.

resource "aws_route_table" "vpn" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "192.168.0.0/16" # On-prem CIDR
    gateway_id     = var.vpn_gw_id
  }

  tags = {
    Name = "VPN-RT"
  }
}
