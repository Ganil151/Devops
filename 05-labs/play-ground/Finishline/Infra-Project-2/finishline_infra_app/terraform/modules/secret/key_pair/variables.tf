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
#  Key Pair Variables
#========================================================
variable "key_name" {
  description = "Name of the key pair to be used for the instances"
  type        = string
  default     = ""
}

variable "key_algorithm" {
  description = "The algorithm to use for the key pair"
  type        = string
  default     = "RSA"
}

variable "rsa_bits" {
  description = "The number of bits for the RSA key"
  type        = number
  default     = 4096
}


variable "private_key_filename" {
  description = "The filename for the private key"
  type        = string
  default     = ""
}

variable "private_key_directory" {
  description = "The directory where the private key will be stored"
  type        = string
  default     = ""
}

variable "computed_tags" {
  description = "The computed tags for the resources"
  type = map(string)
  default = {}
}

variable "additional_tags" {
  description = "Additional tags to be applied to the resources"
  type = map(string)
  default = {}
}


