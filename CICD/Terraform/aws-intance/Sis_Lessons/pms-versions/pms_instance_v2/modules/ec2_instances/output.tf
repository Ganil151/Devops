output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.petclinic_ms.id
}

output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.petclinic_ms.public_ip
}

output "private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = aws_instance.petclinic_ms.private_ip
}

output "availability_zone" {
  description = "The availability zone where the EC2 instance is launched"
  value       = aws_instance.petclinic_ms.availability_zone
}

output "instance_state" {
  description = "The current state of the EC2 instance (e.g., running, stopped)"
  value       = aws_instance.petclinic_ms.instance_state
}

output "tags" {
  description = "The tags associated with the EC2 instance"
  value       = aws_instance.petclinic_ms.tags
}