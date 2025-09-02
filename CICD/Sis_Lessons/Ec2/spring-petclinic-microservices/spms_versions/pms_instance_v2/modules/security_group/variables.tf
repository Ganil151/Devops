# modules\security_group\variables.tf

variable "ingress" {
  type = list(number)
  description = "List of ingress ports"  
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