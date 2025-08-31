output "key_pair_name" {
  description = "The name of the generated SSH key pair"
  value       = module.key_pair.key_name
}

output "private_key_path" {
  description = "Path to the generated private key file"
  value       = "${module.key_pair.key_name}.pem"
}

output "security_group_id" {
  description = "The ID of the created security group"
  value       = module.security_group.security_group_id
}

output "ec2_instance_id" {
  description = "The ID of the created EC2 instance"
  value       = module.ec2_instance.instance_id
}

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = module.ec2_instance.public_ip
}