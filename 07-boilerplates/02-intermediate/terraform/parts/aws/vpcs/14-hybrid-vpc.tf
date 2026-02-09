# 14. Hybrid VPC
# Connected to on-premises via VPN or Direct Connect.

resource "aws_vpc" "hybrid_vpc" {
  cidr_block = "10.100.0.0/16"
}

# Virtual Private Gateway
resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = aws_vpc.hybrid_vpc.id

  tags = {
    Name = "On-Prem-Connector"
  }
}

# Customer Gateway (Represents on-premises router)
resource "aws_customer_gateway" "on_prem" {
  bgp_asn    = 65000
  ip_address = "203.0.113.12"
  type       = "ipsec.1"

  tags = {
    Name = "Company-HQ-Router"
  }
}

# VPN Connection
resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gw.id
  customer_gateway_id = aws_customer_gateway.on_prem.id
  type                = "ipsec.1"
  static_routes_only  = true
}
