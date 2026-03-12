# =============================================================================
# ALB Module - Output Values
# Finish Line 2026 Infrastructure
# =============================================================================

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.finishline_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.finishline_alb.dns_name
}

output "alb_security_group_id" {
  description = "Security group ID of the ALB"
  value       = aws_security_group.alb_sg.id
}

output "target_group_arn" {
  description = "ARN of the EKS target group"
  value       = aws_lb_target_group.eks_target_group.arn
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener (empty if no certificate provided)"
  value       = length(aws_lb_listener.https) > 0 ? aws_lb_listener.https[0].arn : ""
}
