# Advanced Networking Boilerplate: Multi-VPC Peering (Terraform)

/* 
   This configuration demonstrates how to create a cross-network link 
   between an Application VPC and a Data VPC.
*/

# --- 1. THE PEERING CONNECTION ---
resource "aws_vpc_peering_connection" "app_to_data" {
  peer_vpc_id   = aws_vpc.data_vpc.id
  vpc_id        = aws_vpc.app_vpc.id
  auto_accept   = true

  tags = {
    Name = "VPC Peering: App <-> Data"
  }
}

# --- 2. ROUTING (APP -> DATA) ---
resource "aws_route" "app_to_data_route" {
  route_table_id            = aws_vpc.app_vpc.main_route_table_id
  destination_cidr_block    = aws_vpc.data_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.app_to_data.id
}

# --- 3. ROUTING (DATA -> APP) ---
resource "aws_route" "data_to_app_route" {
  route_table_id            = aws_vpc.data_vpc.main_route_table_id
  destination_cidr_block    = aws_vpc.app_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.app_to_data.id
}

---

# Pro-Tip: The DNS Resolution Edge Case
By default, VPC peering DOES NOT resolve private DNS names across the link. 
To enable this, you must set:
`allow_remote_vpc_dns_resolution = true` 
inside the peering resource options.
