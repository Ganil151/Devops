#============================================================
#  ALB Outputs
#============================================================

output "alb_id" {
  description = "The ID of the ALB"
  value       = aws_lb.finishline_alb.id
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.finishline_alb.arn
}

output "alb_arn_suffix" {
  description = "The ARN suffix of the ALB"
  value       = aws_lb.finishline_alb.arn_suffix
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.finishline_alb.dns_name
}

output "alb_zone_id" {
  description = "The zone ID of the ALB"
  value       = aws_lb.finishline_alb.zone_id
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.finishline_alb_tg.arn
}

output "target_group_id" {
  description = "The ID of the target group"
  value       = aws_lb_target_group.finishline_alb_tg.id
}

output "listener_arn" {
  description = "The ARN of the listener"
  value       = aws_lb_listener.finishline_alb_listener.arn
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.finishline_alb_sg.id
}
