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
#  Key Pair Variables
#============================================================
variable "key_name" {
  description = "Name of the key pair"
  type        = string
}
variable "key_algorithm" {
  description = "Algorithm for the key pair"
  type        = string
}

variable "rsa_bits" {
  description = "Number of bits for the RSA key"
  type        = number
}

variable "computed_private_key_filename" {
  description = "Computed filename for the private key"
  type        = string
  default     = ""
}

variable "computed_private_key_path" {
  description = "Computed path for the private key"
  type        = string
  default     = ""
}

variable "private_key_filename" {
  description = "Filename for the private key"
  type        = string
  default     = ""
}

variable "private_key_directory" {
  description = "Directory for the private key"
  type        = string
  default     = ""
}

variable "file_permission" {
  description = "File permission for the private key"
  type        = string
  default     = "0600"
}
