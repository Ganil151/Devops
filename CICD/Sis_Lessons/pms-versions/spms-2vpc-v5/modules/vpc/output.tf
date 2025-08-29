output "vpc_id" {
  value = aws_vpc.spms_vpc.id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = aws_subnet.spms_subnet.id
}
