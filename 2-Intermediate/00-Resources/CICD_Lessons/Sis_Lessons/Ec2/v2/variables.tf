# Define a variable for the SSH key pair name
variable "key_name" {
  description = "Name of the SSH key pair" # Describes the purpose of this variable
  type        = string                     # Specifies that the variable must be a string
  default     = "sis_key_pair"             # Sets a default value for the key pair name if not provided
}

# Define a variable for the Amazon Machine Image (AMI) ID
variable "ami" {
  description = "Amazon Linux 2023 AMI ID" # Describes the purpose of this variable
  type        = string                     # Specifies that the variable must be a string
  default     = "ami-08a6efd148b1f7504"    # Sets a default AMI ID for Amazon Linux 2023
}

# Define a variable for the EC2 instance type
variable "instance_type" {
  description = "EC2 instance type"        # Describes the purpose of this variable
  type        = string                     # Specifies that the variable must be a string
  default     = "t3.micro"                 # Sets a default instance type (e.g., t3.micro)
}