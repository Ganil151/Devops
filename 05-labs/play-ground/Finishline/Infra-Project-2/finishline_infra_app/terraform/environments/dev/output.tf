# =============================================================================
# Outputs: VPC
# =============================================================================
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.finishline_vpc.vpc_id
}

output "enable_dns_support" {
  description = "Whether DNS support is enabled"
  value       = module.finishline_vpc.enable_dns_support
}

output "enable_dns_hostnames" {
  description = "Whether DNS hostnames are enabled"
  value       = module.finishline_vpc.enable_dns_hostnames
}

output "availability_zone" {
  description = "The availability zone"
  value       = module.finishline_vpc.availability_zone
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.finishline_vpc.vpc_arn
}

output "vpc_cidr" {
  description = "The CIDR block for the VPC"
  value       = module.finishline_vpc.vpc_cidr
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = module.finishline_vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = module.finishline_vpc.private_subnet_id
}

output "nat_gateway_id" {
  description = "The ID of the NAT gateway"
  value       = module.finishline_vpc.nat_gateway_id
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value       = module.finishline_vpc.internet_gateway_id
}

output "eip_id" {
  description = "The ID of the Elastic IP"
  value       = module.finishline_vpc.eip_id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = module.finishline_vpc.public_route_table_id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = module.finishline_vpc.private_route_table_id
}

output "aws_region" {
  description = "The AWS region"
  value       = module.finishline_vpc.aws_region
}

output "key_name" {
  description = "Name of the key pair"
  value       = module.finishline_key.key_name
}

output "key_private_key_filename" {
  description = "Private key filename"
  value       = module.finishline_key.private_key_filename
}

output "key_private_key_pathname" {
  description = "Private key full path"
  value       = module.finishline_key.private_key_pathname
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.finishline_sg.finishline_sg_id
}
