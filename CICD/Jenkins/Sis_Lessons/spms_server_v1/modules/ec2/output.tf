output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.spms-server.id
}

output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.spms-server.public_ip
}

output "private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = aws_instance.spms-server.private_ip
}
