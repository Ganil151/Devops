#============================================================
#  Jumphost Instance Outputs
#============================================================

output "instance_id" {
  description = "ID of the jumphost EC2 instance"
  value       = try(aws_instance.jumphost[0].id, null)
}

output "instance_arn" {
  description = "ARN of the jumphost EC2 instance"
  value       = try(aws_instance.jumphost[0].arn, null)
}

output "instance_private_ip" {
  description = "Private IP address of the jumphost"
  value       = try(aws_instance.jumphost[0].private_ip, null)
}

output "instance_public_ip" {
  description = "Public IP address of the jumphost (if assigned)"
  value       = try(aws_instance.jumphost[0].public_ip, null)
}

output "instance_public_dns" {
  description = "Public DNS name of the jumphost (if assigned)"
  value       = try(aws_instance.jumphost[0].public_dns, null)
}

output "instance_private_dns" {
  description = "Private DNS name of the jumphost"
  value       = try(aws_instance.jumphost[0].private_dns, null)
}

output "instance_availability_zone" {
  description = "Availability zone where the jumphost is running"
  value       = try(aws_instance.jumphost[0].availability_zone, null)
}

output "instance_subnet_id" {
  description = "Subnet ID where the jumphost is running"
  value       = try(aws_instance.jumphost[0].subnet_id, null)
}

output "instance_vpc_id" {
  description = "VPC ID where the jumphost is running"
  value       = try(data.aws_subnet.jumphost[0].vpc_id, null)
}

#============================================================
#  Jumphost Elastic IP Outputs
#============================================================

output "elastic_ip_id" {
  description = "ID of the Elastic IP"
  value       = try(aws_eip.jumphost[0].id, null)
}

output "elastic_ip_allocation_id" {
  description = "Allocation ID of the Elastic IP"
  value       = try(aws_eip.jumphost[0].allocation_id, null)
}

output "elastic_ip_public_ip" {
  description = "Public IP address of the Elastic IP"
  value       = try(aws_eip.jumphost[0].public_ip, null)
}

output "elastic_ip_arn" {
  description = "ARN of the Elastic IP"
  value       = try(aws_eip.jumphost[0].arn, null)
}

#============================================================
#  Jumphost Storage Outputs
#============================================================

output "root_volume_id" {
  description = "ID of the root EBS volume"
  value       = try(aws_instance.jumphost[0].root_block_device[0].volume_id, null)
}

output "ebs_volume_ids" {
  description = "List of additional EBS volume IDs"
  value       = try([for device in aws_instance.jumphost[0].ebs_block_device : device.volume_id], [])
}

#============================================================
#  Jumphost CloudWatch Logs Outputs
#============================================================

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = try(aws_cloudwatch_log_group.jumphost[0].name, null)
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = try(aws_cloudwatch_log_group.jumphost[0].arn, null)
}
