output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.spms_vpc.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.private.id
}

output "db_subnet_id" {
  description = "The ID of the database subnet"
  value       = aws_subnet.db.id
}