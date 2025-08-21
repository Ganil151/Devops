variable "ami_name" {
  description = "The Amazon Machine Image Name"
  type = string
  default = "petclinic_sm"
}
variable "ami" {
  description = "The Amazon Machine Image ID"
  type = string
  default = "ami-08a6efd148b1f7504"
}
variable "instance_type" {
  description = "The instance type to use"
  type = string
  default = "t3.micro"
}

variable "user_data" {
  description = "Petclinic Microservices installation"
  type = string
  default = "${file("script.sh")}"
}

variable "user_data_replace_on_change" {
  description = "Replace data on any changes"
  type = bool
  default = true
}

variable "subnet_id" {
  description = "Subnet Id"
  type = string
}

variable "key_name" {
  description = "Key pair name"
  type = string
}
variable "vpc_id" {
  description = "VPC Id"
  type = string
}

variable "vpc_security_group_ids" {
  description = "Vpc Security Group"
  type = list(string)  
}