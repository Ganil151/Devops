# 14. Blackhole Route Table
# Route traffic to "blackhole" to drop packets (security mitigation).

resource "aws_route" "blackhole" {
  route_table_id         = var.route_table_id
  destination_cidr_block = "192.0.2.0/24" # Malicious/Test CIDR
  # Status: blackhole
}
# (Note: blackhole is usually set by AWS for certain transitions)
# In terraform, you can sometimes see it in plan but it's often a transient state.
