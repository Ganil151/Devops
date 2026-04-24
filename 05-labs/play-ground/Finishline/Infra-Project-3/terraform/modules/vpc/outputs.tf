# =============================================================================
# VPC Module - Output Values
# Finish Line 2026 Infrastructure
# =============================================================================

output "main_vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.finishline_vpc.id
}

output "main_public_subnet_ids" {
  description = "List of IDs for all public subnets"
  value       = aws_subnet.finishline_public_subnet[*].id
}

output "main_private_subnet_ids" {
  description = "List of IDs for all private subnets"
  value       = aws_subnet.finishline_private_subnet[*].id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.finishline_vpc.cidr_block
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.finishline_igw.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}
