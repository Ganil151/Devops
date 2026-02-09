# 09. ALB with WAF Integration
# Protecting the load balancer with AWS Web Application Firewall.

resource "aws_wafv2_web_acl_association" "lb_waf" {
  resource_arn = aws_lb.public_alb.arn
  web_acl_arn  = var.waf_web_acl_arn
}
