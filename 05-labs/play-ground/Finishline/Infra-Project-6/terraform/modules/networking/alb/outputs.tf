#============================================================
#  ALB Outputs
#============================================================
output "alb_id" {
  description = "ID of the ALB"
  value       = aws_alb.finishline_alb.id
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_alb.finishline_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_alb.finishline_alb.dns_name
}

output "alb_name" {
  description = "Name of the ALB"
  value       = aws_alb.finishline_alb.name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB"
  value       = aws_alb.finishline_alb.zone_id
}

#============================================================
#  Target Group Outputs
#============================================================
output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.finishline_alb_tg.arn
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.finishline_alb_tg.name
}

output "target_group_port" {
  description = "Port of the target group"
  value       = aws_lb_target_group.finishline_alb_tg.port
}

output "target_group_protocol" {
  description = "Protocol of the target group"
  value       = aws_lb_target_group.finishline_alb_tg.protocol
}

output "target_group_id" {
  description = "ID of the target group"
  value       = aws_lb_target_group.finishline_alb_tg.id
}

#============================================================
#  Listener Outputs
#============================================================
output "listener_arn" {
  description = "ARN of the listener"
  value       = aws_lb_listener.finishline_alb_listener.arn
}

output "listener_port" {
  description = "Port of the listener"
  value       = aws_lb_listener.finishline_alb_listener.port
}

output "listener_protocol" {
  description = "Protocol of the listener"
  value       = aws_lb_listener.finishline_alb_listener.protocol
}

#============================================================
#  Security Group Outputs
#============================================================
output "security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.finishline_alb_sg.id
}

output "security_group_name" {
  description = "Name of the ALB security group"
  value       = aws_security_group.finishline_alb_sg.name
}

output "security_group_arn" {
  description = "ARN of the ALB security group"
  value       = aws_security_group.finishline_alb_sg.arn
}
