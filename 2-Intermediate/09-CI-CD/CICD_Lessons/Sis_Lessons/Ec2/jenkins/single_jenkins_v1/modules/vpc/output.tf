output "vpc_id" {
  value = aws_vpc.jenkins_vpc.id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = aws_subnet.jenkins_subnet.id
}
