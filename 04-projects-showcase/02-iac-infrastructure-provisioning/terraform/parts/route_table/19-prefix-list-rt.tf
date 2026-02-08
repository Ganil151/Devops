# 19. Managed Prefix List Route Table
# Simplified routing using managed prefix lists (e.g., CloudFront).

resource "aws_route" "prefix_list" {
  route_table_id         = var.route_table_id
  destination_prefix_list_id = var.prefix_list_id
  gateway_id             = var.igw_id
}
