output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.terra_vpc.id
}

output "public_subnet_ids" {
  description = "List of IDs for public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "List of IDs for private subnets"
  value       = aws_subnet.private_subnets[*].id
}