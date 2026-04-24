#========================================================
#  Project Variables
#========================================================
variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = ""
}

variable "environment" {
  description = "The environment name"
  type        = string
  default     = ""
}

variable "managedBy" {
  description = "The team or individual managing the resources"
  type        = string
  default     = ""
}

variable "additional_tags" { 
  description = "The additional tags for the resources"
  type        = map(string)
  default     = {}
}

#========================================================
#  Jump Host Bastion Ec2 Variables
#========================================================
variable "key_name" {
  description = "Name of the key pair to be used for the instances"
  type        = string
  default     = ""
}
variable "jumphost_name" {
  description = "The name of the jump host"
  type        = string
  default     = ""
}
variable "jumphost_instance_type" {
  description = "The instance type for the jump host"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs for the EKS cluster"
  type        = list(string)
  default     = []
}

variable "availability_zone" {
  type    = list(string)
  default = []
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile for the jump host"
  type        = string
  default     = ""
}

variable "root_block_device" {
  description = "Configuration for the root block device"
  type = object({
    volume_type           = string
    volume_size           = number
    delete_on_termination = bool
    encrypted             = bool
  })
  default = {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true
  }
}
