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

#========================================================
#  VPC Variables
#========================================================
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  default     = ""
}

#========================================================
#  Security Group Variables
#========================================================
variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = ""
  
}

variable "security_group_description" {
  description = "The description for the security group"
  type = string
  default = ""
}

variable "ingress_rules" {
  description = "The ingress rules for the security group"
  type        = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default     = []
}

variable "egress_rules" {
  description = "The egress rules for the security group"
  type        = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default     = []
}
