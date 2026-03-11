#==============================================================
# ALB Outputs
#==============================================================
output "alb_id" {
  description = "The ID of the load balancer"
  value       = aws_lb.alb.id
}

output "alb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.alb.arn
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.alb.dns_name
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer"
  value       = aws_lb.alb.zone_id
}

output "alb_security_groups" {
  description = "The security groups of the load balancer"
  value       = aws_lb.alb.security_groups
}

#==============================================================
# Target Group Outputs
#==============================================================
output "target_group_id" {
  description = "The ID of the target group"
  value       = aws_lb_target_group.alb_tg.id
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.alb_tg.arn
}

output "target_group_name" {
  description = "The name of the target group"
  value       = aws_lb_target_group.alb_tg.name
}

#==============================================================
# Listener Outputs
#==============================================================
output "listener_http_arn" {
  description = "The ARN of the HTTP listener"
  value       = aws_lb_listener.alb_listener_http.arn
}

output "listener_https_arn" {
  description = "The ARN of the HTTPS listener (if configured)"
  value       = try(aws_lb_listener.alb_listener_https[0].arn, "")
}

#==============================================================
# ALB Endpoint
#==============================================================
output "alb_endpoint" {
  description = "The endpoint URL of the ALB"
  value       = "http://${aws_lb.alb.dns_name}"
}
