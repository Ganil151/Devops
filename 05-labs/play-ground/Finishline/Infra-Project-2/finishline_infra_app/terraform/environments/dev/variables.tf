#========================================================
#  Project Variables
#========================================================
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "managedBy" {
  type = string
}

variable "aws_region" {
  type = string
}

#========================================================
#  VPC Variables
#========================================================
variable "vpc_cidr" {
  type = string
}

variable "enable_dns_support" {
  type = bool
}

variable "enable_dns_hostnames" {
  type = bool
}

variable "availability_zone" {
  type = list(string)
}

variable "public_subnet_cidr" {
  type = list(string)
}

variable "private_subnet_cidr" {
  type = list(string)
}

#========================================================
#  Security Group Variables
#========================================================
variable "security_group_name" {
  type = string
}

variable "ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "egress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "security_group_description" {
  type = string
}

#========================================================
#  Key Pair Variables
#========================================================
variable "key_name" {
  type = string
}

variable "key_algorithm" {
  type = string
}

variable "rsa_bits" {
  type = number
}

variable "private_key_filename" {
  type = string
}

variable "private_key_directory" {
  type = string
}

variable "computed_tags" {
  type = map(string)
}

variable "additional_tags" {
  type = map(string)
}

#========================================================
#  IAM & EKS Variables
#========================================================
variable "cluster_name" {
  type = string
}

variable "ami_type" {
  type = string
}

variable "cluster_disk_size" {
  type = number
}

variable "is_role_enabled" {
  type = bool
}

variable "is_eks_nodegroup_role_enabled" {
  type = bool
}

variable "is_eks_cluster_enabled" {
  type = bool
}

variable "cluster_version" {
  type = string
}

variable "cluster_enabled_log_types" {
  type = list(string)
}

variable "cluster_role_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "create_ondemand_nodegroup" {
  type = bool
}

variable "desired_capacity_on_demand" {
  type = number
}

variable "min_capacity_on_demand" {
  type = number
}

variable "max_capacity_on_demand" {
  type = number
}

variable "ondemand_instance_types" {
  type = list(string)
}

variable "desired_capacity_on_spot" {
  type = number
}

variable "min_capacity_on_spot" {
  type = number
}

variable "max_capacity_on_spot" {
  type = number
}

variable "spot_instance_types" {
  type = list(string)
}

variable "endpoint_private_access" {
  type = bool
}

variable "endpoint_public_access" {
  type = bool
}

variable "eks_oidc_url" {
  type = string
}

variable "oidc_thumbprint" {
  type = list(string)
}

variable "oidc_namespace" {
  type = string
}

variable "oidc_service_account" {
  type = string
}

variable "s3_bucket_arn" {
  type = string
}

variable "s3_access_type" {
  type = string
}

variable "s3_prefix" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "iam_instance_profile_name" {
  type = string
}

variable "ondemand_taints" {
  type = list(string)
}

variable "spot_taints" {
  type = list(string)
}

#========================================================
#  Jump Host Variables
#========================================================
variable "jumphost_instance_type" {
  type = string
}

variable "jumphost_name" {
  type = string
}

variable "root_block_device" {
  type = object({
    volume_type           = string
    volume_size           = number
    delete_on_termination = bool
    encrypted             = bool
  })
}

#========================================================
#  ALB Variables
#========================================================
variable "alb_name" {
  type = string
}

variable "alb_internal" {
  type = bool
}

variable "alb_load_balancer_type" {
  type = string
}

variable "enable_deletion_protection" {
  type = bool
}

variable "enable_http2" {
  type = bool
}

variable "enable_cross_zone_load_balancing" {
  type = bool
}

variable "enable_access_logs" {
  type = bool
}

variable "access_logs_s3_bucket" {
  type = string
}

variable "access_logs_s3_prefix" {
  type = string
}

variable "target_group_name" {
  type = string
}

variable "target_group_port" {
  type = number
}

variable "target_group_protocol" {
  type = string
}

variable "target_type" {
  type = string
}

variable "health_check_enabled" {
  type = bool
}

variable "health_check_healthy_threshold" {
  type = number
}

variable "health_check_unhealthy_threshold" {
  type = number
}

variable "health_check_timeout" {
  type = number
}

variable "health_check_interval" {
  type = number
}

variable "health_check_path" {
  type = string
}

variable "health_check_matcher" {
  type = string
}

variable "listener_port" {
  type = number
}

variable "listener_protocol" {
  type = string
}

variable "listener_default_action" {
  type = string
}

variable "ssl_certificate_arn" {
  type = string
}

variable "stickiness_type" {
  type = string
}

variable "stickiness_enabled" {
  type = bool
}

variable "stickiness_cookie_duration" {
  type = number
}

variable "deregistration_delay" {
  type = number
}
