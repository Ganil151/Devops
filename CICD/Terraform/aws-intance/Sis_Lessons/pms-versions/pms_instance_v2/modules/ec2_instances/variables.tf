variable "name" {
  type    = string
  default = "Petclinic_Microservices_App01"
}

variable "ami" {
  type    = string
  default = "ami-08a6efd148b1f7504"
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type = string
  
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = "sis_key_pair"
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = ["sg-0ac0d456f51769942"]
}

variable "user_data_replace_on_change" {
  type    = bool
  default = true
}
