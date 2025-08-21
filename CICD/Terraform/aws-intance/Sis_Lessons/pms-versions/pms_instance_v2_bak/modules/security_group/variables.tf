# modules\security_group\variables.tf

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

variable "name" {
  description = "Name of the security group"
  type        = string
  default     = "petclinic_sg"
  
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "petclinic_vpc" {  
  description = "ID of the VPC"
  type        = string  
}