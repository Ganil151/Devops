variable "vpc_name" {
  description = "Name of the VPC"
  type = string
  default = "petclinic_vpc"
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "vpc_cidr_block" {
  description = "VPC cidr_block"
  type = string
  default = "10.0.0.0/16"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type = string
  default = "petclinic_subnet"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type = string
  default = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability Zone for the subnet"
  type = string
  default = "us-east-1a"
}

variable "igw_name" {
  description = "Name of the Internet Gateway"
  type = string
  default = "petclinic_igw"
}