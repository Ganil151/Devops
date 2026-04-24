#========================================================
#  VPC Module - Output
#========================================================
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.finishline_vpc.id
}

output "aws_region" {
  description = "The AWS region"
  value       = var.aws_region
}

output "enable_dns_support" {
  description = "Whether DNS support is enabled"
  value       = aws_vpc.finishline_vpc.enable_dns_support
}

output "enable_dns_hostnames" {
  description = "Whether DNS hostnames are enabled"
  value       = aws_vpc.finishline_vpc.enable_dns_hostnames
}

output "availability_zone" {
  description = "The availability zones"
  value       = var.availability_zone
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.finishline_vpc.arn
}

output "vpc_cidr" {
  description = "The CIDR block for the VPC"
  value       = aws_vpc.finishline_vpc.cidr_block
}

output "public_subnet_id" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.finishline_public_subnet[*].id
}

output "private_subnet_id" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.finishline_private_subnet[*].id
}

output "nat_gateway_id" {
  description = "The ID of the NAT gateway"
  value       = aws_nat_gateway.finishline_nat_gateway.id
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value       = aws_internet_gateway.finishline_igw.id
}

output "eip_id" {
  description = "The ID of the Elastic IP"
  value       = aws_eip.finishline_eip.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.finishline_public_route_table.id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.finishline_private_route_table.id
}

output "public_nacl_id" {
  description = "The ID of the public network ACL"
  value       = aws_network_acl.finishline_public_nacl.id
}

output "private_nacl_id" {
  description = "The ID of the private network ACL"
  value       = aws_network_acl.finishline_private_nacl.id
}