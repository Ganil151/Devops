output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.web_server[*].id
}

output "instance_public_ips" {
  description = "Public IP addresses of the instances"
  value       = aws_instance.web_server[*].public_ip
}

output "instance_public_dns" {
  description = "Public DNS names of the instances"
  value       = aws_instance.web_server[*].public_dns
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.web_sg.id
}

output "web_urls" {
  description = "URLs to access the web servers"
  value       = [for ip in aws_instance.web_server[*].public_ip : "http://${ip}"]
}