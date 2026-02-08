variable "environment" {
  type    = string
  default = "dev"
}

variable "primary" {
  type    = string
  default = "us-east-1"
}


variable "secondary" {
  type    = string
  default = "us-west-2"
}

variable "primary_vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "secondary_vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "primary_subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "secondary_subnet_cidr" {
  default = "10.1.0.0/24"
}

variable "key_name" {
  default = 
}

