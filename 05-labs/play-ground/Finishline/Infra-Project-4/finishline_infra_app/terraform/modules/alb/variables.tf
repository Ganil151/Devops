#============================================================
#  ALB Variables
#============================================================

# Project Variables
variable "project_name" {
  description = "The name of the project"
  type        = string

  validation {
    condition = can(regex(
      "^[a-zA-Z][a-zA-Z0-9-]{2,20}[a-zA-Z0-9]$", var.project_name
    ))
    error_message = "Project name must be 4-24 chars, start with letter, lowercase alphanumeric and hyphens only."
  }
}

variable "environment" {
  description = "The environment for the ALB"
  type        = string

  validation {
    condition = can(regex(
      "^[a-zA-Z][a-zA-Z0-9-]{2,20}[a-zA-Z0-9]$", var.environment
    ))
    error_message = "Environment must be 4-24 chars, start with letter, lowercase alphanumeric and hyphens only."
  }
}

variable "manage_by" {
  description = "Whether to manage the ALB by Terraform"
  type        = bool
}

variable "availability_zone" {
  description = "The availability zones for the ALB"
  type        = list(string)
}

# ALB Configuration Variables
variable "alb_name" {
  description = "The name of the ALB"
  type        = string
}

variable "alb_internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}

variable "alb_load_balancer_type" {
  description = "The type of load balancer"
  type        = string
  default     = "application"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB"
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Enable HTTP/2 for the ALB"
  type        = bool
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

variable "enable_access_logs" {
  description = "Enable access logs for the ALB"
  type        = bool
  default     = false
}

variable "access_logs_s3_bucket" {
  description = "The S3 bucket name for access logs"
  type        = string
  default     = ""
}

variable "access_logs_s3_prefix" {
  description = "The S3 prefix for access logs"
  type        = string
  default     = ""
}

# Target Group Configuration Variables
variable "target_group_name" {
  description = "The name of the target group"
  type        = string
}

variable "target_group_port" {
  description = "The port of the target group"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "The protocol of the target group"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "The target type of the target group"
  type        = string
  default     = "ip"
}

# Health Check Configuration Variables
variable "health_check_enabled" {
  description = "Enable health checks for the target group"
  type        = bool
  default     = true
}

variable "health_check_healthy_threshold" {
  description = "The number of consecutive health checks required before considering a target healthy"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "The number of consecutive health checks required before considering a target unhealthy"
  type        = number
  default     = 2
}

variable "health_check_timeout" {
  description = "The health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_interval" {
  description = "The health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_path" {
  description = "The health check path"
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "The HTTP matcher for health check"
  type        = string
  default     = "200"
}

# Listener Configuration Variables
variable "listener_port" {
  description = "The port for the ALB listener"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "The protocol for the ALB listener"
  type        = string
  default     = "HTTP"
}

variable "listener_default_action" {
  description = "The default action for the listener"
  type        = string
  default     = "forward"
}

variable "ssl_certificate_arn" {
  description = "The ARN of the SSL certificate"
  type        = string
  default     = ""
}

# Stickiness Configuration Variables
variable "stickiness_type" {
  description = "The stickiness type"
  type        = string
  default     = "lb_cookie"
}

variable "stickiness_enabled" {
  description = "Enable stickiness"
  type        = bool
  default     = true
}

variable "stickiness_cookie_duration" {
  description = "The stickiness cookie duration in seconds"
  type        = number
  default     = 86400
}

variable "deregistration_delay" {
  description = "The deregistration delay in seconds"
  type        = number
  default     = 30
}

# Network Configuration Variables
variable "vpc_id" {
  description = "The VPC ID for the ALB"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs for the ALB"
  type        = list(string)
}
