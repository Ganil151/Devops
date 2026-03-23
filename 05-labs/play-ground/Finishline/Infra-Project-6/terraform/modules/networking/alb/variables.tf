#============================================================
#  Project Variables
#============================================================
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
}

variable "managed_by" {
  description = "Team managing this resource"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "computed_tags" {
  description = "Additional tags to apply"
  type        = map(string)
  default     = {}
}
#============================================================
#  ALB Variables
#============================================================
variable "alb_internal" {
  description = "Whether the ALB is internal"
  type        = bool
}

variable "alb_load_balancer_type" {
  description = "Type of the ALB"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
}

variable "enable_http2" {
  description = "Whether to enable HTTP/2"
  type        = bool
}

variable "enable_cross_zone_load_balancing" {
  description = "Whether to enable cross-zone load balancing"
  type        = bool
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB"
  type        = list(string)
}

variable "enable_access_logs" {
  description = "Whether to enable access logs"
  type        = bool
}

variable "access_logs_s3_bucket" {
  description = "S3 bucket for access logs"
  type        = string

  validation {
    condition     = var.enable_access_logs == false || var.access_logs_s3_bucket != ""
    error_message = "access_logs_s3_bucket must be provided when enable_access_logs is true"
  }
}

variable "access_logs_s3_prefix" {
  description = "Prefix for access logs in S3"
  type        = string
}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
}

variable "target_group_protocol" {
  description = "Protocol for the target group"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "target_type" {
  description = "Type of the target"
  type        = string
}

variable "health_check_enabled" {
  description = "Whether to enable health checks"
  type        = bool
}

variable "healthy_threshold" {
  description = "Number of consecutive successful health checks to consider a target healthy"
  type        = number
}

variable "unhealthy_threshold" {
  description = "Number of consecutive failed health checks to consider a target unhealthy"
  type        = number
}

variable "health_check_timeout" {
  description = "Timeout for health checks"
  type        = number
}

variable "health_check_interval" {
  description = "Interval for health checks"
  type        = number
}
variable "health_check_path" {
  description = "Path for health checks"
  type        = string
}
variable "health_check_matcher" {
  description = "Matcher for health checks"
  type        = string
}
variable "stickiness_type" {
  description = "Type of stickiness"
  type        = string
}

variable "stickiness_enabled" {
  description = "Whether to enable stickiness"
  type        = bool
}

variable "stickiness_cookie_duration" {
  description = "Duration of the stickiness cookie"
  type        = number
}

variable "listener_port" {
  description = "Port for the listener"
  type        = number
}

variable "listener_protocol" {
  description = "Protocol for the listener"
  type        = string
}

variable "listener_default_action" {
  description = "Default action for the listener"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}
