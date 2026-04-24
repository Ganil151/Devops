# =============================================================================
# VPC Module Outputs
# Module: vpc
# Assignment Reference: Finish Line 2026 §51, §55, §56, §57
# =============================================================================

# -----------------------------------------------------------------------------
# VPC Outputs
# -----------------------------------------------------------------------------

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_default_security_group_id" {
  description = "The ID of the default security group"
  value       = aws_vpc.main.default_security_group_id
}

output "vpc_default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = aws_vpc.main.default_network_acl_id
}

output "vpc_default_route_table_id" {
  description = "The ID of the default route table"
  value       = aws_vpc.main.default_route_table_id
}

# -----------------------------------------------------------------------------
# Internet Gateway Outputs
# -----------------------------------------------------------------------------

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "internet_gateway_arn" {
  description = "The ARN of the Internet Gateway"
  value       = aws_internet_gateway.main.arn
}

# -----------------------------------------------------------------------------
# Subnet Outputs
# -----------------------------------------------------------------------------

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block
}

output "public_subnet_availability_zones" {
  description = "List of public subnet availability zones"
  value       = aws_subnet.public[*].availability_zone
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = aws_subnet.private[*].cidr_block
}

output "private_subnet_availability_zones" {
  description = "List of private subnet availability zones"
  value       = aws_subnet.private[*].availability_zone
}

# -----------------------------------------------------------------------------
# NAT Gateway Outputs
# -----------------------------------------------------------------------------

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "nat_eip_allocation_id" {
  description = "The allocation ID of the Elastic IP for NAT Gateway"
  value       = aws_eip.nat.id
}

output "nat_eip_public_ip" {
  description = "The public IP of the Elastic IP for NAT Gateway"
  value       = aws_eip.nat.public_ip
}

# -----------------------------------------------------------------------------
# Route Table Outputs
# -----------------------------------------------------------------------------

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private.id
}

# -----------------------------------------------------------------------------
# Availability Zone Outputs
# -----------------------------------------------------------------------------

output "availability_zones" {
  description = "List of availability zones used"
  value       = var.availability_zones
}

# -----------------------------------------------------------------------------
# Composite Outputs
# -----------------------------------------------------------------------------

output "vpc_details" {
  description = "Complete VPC details for documentation"
  value = {
    vpc_id                  = aws_vpc.main.id
    vpc_arn                 = aws_vpc.main.arn
    vpc_cidr                = aws_vpc.main.cidr_block
    internet_gateway_id     = aws_internet_gateway.main.id
    nat_gateway_ids         = aws_nat_gateway.main[*].id
    public_subnet_ids       = aws_subnet.public[*].id
    private_subnet_ids      = aws_subnet.private[*].id
    public_route_table_id   = aws_route_table.public.id
    private_route_table_id  = aws_route_table.private.id
    availability_zones      = var.availability_zones
    enable_dns_support      = aws_vpc.main.enable_dns_support
    enable_dns_hostnames    = aws_vpc.main.enable_dns_hostnames
  }
}
