#========================================================
#  Project Variables
#========================================================
variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "managedBy" {
  description = "The team or individual managing the resources"
  type        = string
}

variable "additional_tags" {
  description = "The additional tags for the resources"
  type        = map(string)
  default     = {}
}

#========================================================
#  VPC & Network Variables
#========================================================
variable "vpc_id" {
  description = "The VPC ID where ALB will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for ALB"
  type        = list(string)
}

#========================================================
#  ALB Configuration Variables
#========================================================
variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = ""
}

variable "alb_internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}

variable "alb_load_balancer_type" {
  description = "Type of load balancer (application, network, gateway)"
  type        = string
  default     = "application"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Enable HTTP/2 for ALB"
  type        = bool
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

variable "enable_access_logs" {
  description = "Enable access logs for ALB"
  type        = bool
  default     = false
}

variable "access_logs_s3_bucket" {
  description = "S3 bucket for ALB access logs"
  type        = string
  default     = ""
}

variable "access_logs_s3_prefix" {
  description = "S3 prefix for ALB access logs"
  type        = string
  default     = "alb-logs"
}

#========================================================
#  Target Group Variables
#========================================================
variable "target_group_name" {
  description = "Name of the target group"
  type        = string
  default     = ""
}

variable "target_group_port" {
  description = "Port for target group"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol for target group (HTTP, HTTPS, TCP, TLS)"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Type of target (instance, ip, lambda, alb)"
  type        = string
  default     = "ip"
}

variable "health_check_enabled" {
  description = "Enable health checks"
  type        = bool
  default     = true
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health checks successes required"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures required"
  type        = number
  default     = 2
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_path" {
  description = "Path for health checks"
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "HTTP codes to use when checking for a successful response"
  type        = string
  default     = "200"
}

#========================================================
#  Listener Variables
#========================================================
variable "listener_port" {
  description = "Port for listener"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Protocol for listener (HTTP, HTTPS, TCP, TLS)"
  type        = string
  default     = "HTTP"
}

variable "listener_default_action" {
  description = "Default action for listener (forward, redirect, fixed-response)"
  type        = string
  default     = "forward"
}

variable "ssl_certificate_arn" {
  description = "ARN of SSL certificate for HTTPS listener"
  type        = string
  default     = ""
}

#========================================================
#  Stickiness Variables
#========================================================
variable "stickiness_type" {
  description = "Type of stickiness (lb_cookie, app_cookie)"
  type        = string
  default     = "lb_cookie"
}

variable "stickiness_enabled" {
  description = "Enable stickiness"
  type        = bool
  default     = true
}

variable "stickiness_cookie_duration" {
  description = "Cookie duration in seconds"
  type        = number
  default     = 86400
}

#========================================================
#  Deregistration Delay Variables
#========================================================
variable "deregistration_delay" {
  description = "Time to wait for in-flight requests to complete while deregistering"
  type        = number
  default     = 30
}
