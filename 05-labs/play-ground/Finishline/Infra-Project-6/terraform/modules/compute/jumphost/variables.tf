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
}

variable "computed_tags" {
  description = "Additional tags to apply"
  type        = map(string)
  default     = {}
}

#============================================================
#  Jumphost Instance Variables
#============================================================
variable "instance_name" {
  description = "Name of the jumphost instance"
  type        = string
}

variable "is_jumphost_enabled" {
  description = "Whether to enable jumphost resources"
  type        = bool
  default     = false
}

variable "ami_id" {
  description = "AMI ID for the jumphost instance (leave empty for latest Amazon Linux 2)"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type for the jumphost"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID to launch the jumphost in"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for the jumphost"
  type        = list(string)
}

variable "key_pair_name" {
  description = "Name of the SSH key pair to use"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile to associate"
  type        = string
  default     = ""
}

#============================================================
#  Network Configuration Variables
#============================================================
variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = true
}

variable "private_ip" {
  description = "Private IP address to assign to the instance"
  type        = string
  default     = ""
}

variable "allocate_eip" {
  description = "Whether to allocate an Elastic IP for the jumphost"
  type        = bool
  default     = false
}

#============================================================
#  Storage Configuration Variables
#============================================================
variable "root_volume_type" {
  description = "Type of the root volume (gp2, gp3, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "root_volume_encrypted" {
  description = "Whether to encrypt the root volume"
  type        = bool
  default     = true
}

variable "root_volume_kms_key_id" {
  description = "KMS key ID for root volume encryption"
  type        = string
  default     = ""
}

variable "root_volume_delete_on_termination" {
  description = "Whether to delete the root volume on termination"
  type        = bool
  default     = true
}

variable "ebs_block_devices" {
  description = "List of additional EBS block devices to attach"
  type = list(object({
    device_name           = string
    volume_type           = optional(string, "gp3")
    volume_size           = optional(number, 100)
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string, null)
    delete_on_termination = optional(bool, false)
    iops                  = optional(number, null)
    throughput            = optional(number, null)
  }))
  default = []
}

#============================================================
#  Metadata Options Variables (IMDSv2)
#============================================================
variable "metadata_http_endpoint" {
  description = "Whether the instance metadata endpoint is enabled"
  type        = string
  default     = "enabled"
}

variable "metadata_http_tokens" {
  description = "Whether IMDSv2 tokens are required (required or optional)"
  type        = string
  default     = "required"
}

variable "metadata_http_put_response_hop_limit" {
  description = "Desired HTTP PUT response hop limit for instance metadata requests"
  type        = number
  default     = 1
}

variable "metadata_instance_metadata_tags" {
  description = "Whether to enable instance metadata tags"
  type        = string
  default     = "disabled"
}

#============================================================
#  Monitoring and Logging Variables
#============================================================
variable "detailed_monitoring" {
  description = "Whether to enable detailed monitoring"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_logs" {
  description = "Whether to create CloudWatch log group for the jumphost"
  type        = bool
  default     = false
}

variable "cloudwatch_log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.cloudwatch_log_retention_days)
    error_message = "cloudwatch_log_retention_days must be one of: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, or 3653."
  }
}

#============================================================
#  User Data Variables
#============================================================
variable "user_data" {
  description = "User data script to run on instance startup (leave empty to use default install-tools script)"
  type        = string
  default     = ""
}

variable "user_data_replace_on_change" {
  description = "Whether to replace the instance when user_data changes"
  type        = bool
  default     = false
}

variable "use_install_tools_script" {
  description = "Whether to use the default install-tools user data script"
  type        = bool
  default     = true
}

variable "install_tools_script_path" {
  description = "Path to the install-tools script (required when use_install_tools_script is true)"
  type        = string
  default     = ""
}

#============================================================
#  Maintenance Options Variables
#============================================================
variable "auto_recovery" {
  description = "Whether to enable automatic recovery of the instance"
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "disabled"], var.auto_recovery)
    error_message = "auto_recovery must be either 'default' or 'disabled'."
  }
}
