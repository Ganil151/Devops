output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.finishline_vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.finishline_vpc.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.finishline_public_subnet[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.finishline_private_subnet[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.finishline_igw.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.finishline_public_rt.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.finishline_private_rt.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.finishline_nat_gw.id
}

output "nat_gateway_eip_id" {
  description = "Elastic IP ID for NAT Gateway"
  value       = aws_eip.main.id
}
