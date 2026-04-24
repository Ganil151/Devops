# =============================================================================
# ALB Module Outputs
# Module: alb
# Assignment Reference: Finish Line 2026 §31, §62, §65
# - Shared Application Load Balancer with IngressGroup mechanism
# =============================================================================

# -----------------------------------------------------------------------------
# ALB Identity
# -----------------------------------------------------------------------------

output "alb_id" {
  description = "The ID of the Application Load Balancer"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_name" {
  description = "The name of the Application Load Balancer"
  value       = aws_lb.main.name
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "The Route53 Zone ID for the ALB (for alias records)"
  value       = aws_lb.main.zone_id
}

# -----------------------------------------------------------------------------
# Security Group
# -----------------------------------------------------------------------------

output "security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "security_group_arn" {
  description = "The ARN of the ALB security group"
  value       = aws_security_group.alb_sg.arn
}

output "security_group_name" {
  description = "The name of the ALB security group"
  value       = aws_security_group.alb_sg.name
}

# -----------------------------------------------------------------------------
# Listeners
# -----------------------------------------------------------------------------

output "http_listener_arn" {
  description = "The ARN of the HTTP listener (port 80)"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "The ARN of the HTTPS listener (port 443)"
  value       = try(aws_lb_listener.https[0].arn, null)
}

output "http_listener_id" {
  description = "The ID of the HTTP listener"
  value       = aws_lb_listener.http.id
}

# -----------------------------------------------------------------------------
# Target Group
# -----------------------------------------------------------------------------

output "default_target_group_arn" {
  description = "The ARN of the default target group"
  value       = aws_lb_target_group.default.arn
}

output "default_target_group_name" {
  description = "The name of the default target group"
  value       = aws_lb_target_group.default.name
}

output "default_target_group_port" {
  description = "The port of the default target group"
  value       = aws_lb_target_group.default.port
}

# -----------------------------------------------------------------------------
# IngressGroup Configuration
# -----------------------------------------------------------------------------

output "ingress_group_name" {
  description = "The ingress group name for AWS LB Controller"
  value       = var.ingress_group
}

output "ingress_group_tags" {
  description = "Tags required for AWS LB Controller IngressGroup discovery"
  value = {
    "elbv2.k8s.aws/cluster" = var.cluster_name
    "ingress_group"         = var.ingress_group
  }
}

# -----------------------------------------------------------------------------
# CloudWatch Alarms
# -----------------------------------------------------------------------------

output "alb_5xx_alarm_arn" {
  description = "The ARN of the 5XX error alarm for the ALB"
  value       = try(aws_cloudwatch_metric_alarm.alb_5xx[0].arn, null)
}

output "target_5xx_alarm_arn" {
  description = "The ARN of the 5XX error alarm for targets"
  value       = try(aws_cloudwatch_metric_alarm.target_5xx[0].arn, null)
}

# -----------------------------------------------------------------------------
# Composite Outputs
# -----------------------------------------------------------------------------

output "alb_details" {
  description = "Complete ALB details for documentation and integration"
  value = {
    id                  = aws_lb.main.id
    arn                 = aws_lb.main.arn
    name                = aws_lb.main.name
    dns_name            = aws_lb.main.dns_name
    zone_id             = aws_lb.main.zone_id
    security_group_id   = aws_security_group.alb_sg.id
    http_listener_arn   = aws_lb_listener.http.arn
    https_listener_arn  = try(aws_lb_listener.https[0].arn, null)
    target_group_arn    = aws_lb_target_group.default.arn
    ingress_group       = var.ingress_group
    cluster_tag         = var.cluster_name
    subnets             = var.public_subnet_ids
    vpc_id              = var.vpc_id
  }
}

# -----------------------------------------------------------------------------
# Kubernetes Integration Helper
# -----------------------------------------------------------------------------

output "kubernetes_annotations" {
  description = "Kubernetes annotations for Ingress resources to use this ALB"
  value = {
    "kubernetes.io/ingress.class"                 = "alb"
    "alb.ingress.kubernetes.io/group.name"        = var.ingress_group
    "alb.ingress.kubernetes.io/scheme"            = "internet-facing"
    "alb.ingress.kubernetes.io/target-type"       = "ip"
    "alb.ingress.kubernetes.io/vpc-id"            = var.vpc_id
    "alb.ingress.kubernetes.io/subnets"           = join(",", var.public_subnet_ids)
    "alb.ingress.kubernetes.io/security-groups"   = aws_security_group.alb_sg.id
    "alb.ingress.kubernetes.io/listen-ports"      = var.certificate_arn != "" ? "[{\"HTTP\": 80}, {\"HTTPS\": 443}]" : "[{\"HTTP\": 80}]"
    "alb.ingress.kubernetes.io/ssl-redirect"      = var.certificate_arn != "" ? "443" : "80"
    "alb.ingress.kubernetes.io/certificate-arn"   = var.certificate_arn
    "alb.ingress.kubernetes.io/ssl-policy"        = var.ssl_policy
  }
}
