output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.petclinic_vpc.id
}

output "subnet_id" {
  description = "Subnet ID for the public subnet"
  value       = aws_subnet.petclinic_subnet.id
}

output "internet_gateway_id" {
  description = "The ID of the created Internet Gateway"
  value       = aws_internet_gateway.petclinic_igw.id
}

output "route_table_id" {
  description = "The ID of the created route table"
  value       = aws_route_table.petclinic_route_table.id
}