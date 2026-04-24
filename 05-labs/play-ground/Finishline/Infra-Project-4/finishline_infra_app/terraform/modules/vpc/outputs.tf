#==========================================================
# VPC Outputs
#==========================================================

output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.finishline_vpc.id
}

output "vpc_cidr" {
  description = "The VPC CIDR block"
  value       = aws_vpc.finishline_vpc.cidr_block
}

output "vpc_default_security_group_id" {
  description = "The default security group ID for the VPC"
  value       = aws_vpc.finishline_vpc.default_security_group_id
}

#==========================================================
# Subnet Outputs
#==========================================================

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.finishline_public_subnet[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.finishline_private_subnet[*].id
}

output "public_subnet_azs" {
  description = "List of availability zones for public subnets"
  value       = aws_subnet.finishline_public_subnet[*].availability_zone
}

output "private_subnet_azs" {
  description = "List of availability zones for private subnets"
  value       = aws_subnet.finishline_private_subnet[*].availability_zone
}

#==========================================================
# Internet Gateway Outputs
#==========================================================

output "internet_gateway_id" {
  description = "The Internet Gateway ID"
  value       = aws_internet_gateway.finishline_igw.id
}

#==========================================================
# NAT Gateway Outputs
#==========================================================

output "nat_gateway_id" {
  description = "The NAT Gateway ID"
  value       = aws_nat_gateway.finishline_nat_gw.id
}

output "nat_gateway_allocation_id" {
  description = "The allocation ID for the NAT Gateway EIP"
  value       = aws_nat_gateway.finishline_nat_gw.allocation_id
}

#==========================================================
# Route Table Outputs
#==========================================================

output "public_route_table_id" {
  description = "The public route table ID"
  value       = aws_route_table.finishline_public_route_table.id
}

output "private_route_table_id" {
  description = "The private route table ID"
  value       = aws_route_table.finishline_private_route_table.id
}

#==========================================================
# Network ACL Outputs
#==========================================================

output "public_network_acl_id" {
  description = "The public subnet network ACL ID (internet-facing)"
  value       = aws_network_acl.finishline_network_acl.id
}

#==========================================================
# Key Pair Outputs
#==========================================================

output "key_pair_id" {
  description = "The key pair ID"
  value       = module.key_pair.key_pair_id
}

output "key_pair_key_name" {
  description = "The key pair name"
  value       = module.key_pair.key_pair_key_name
}

output "private_key_path" {
  description = "The path where the private key is saved"
  value       = module.key_pair.private_key_path
}
