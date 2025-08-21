# modules\ec2_instance\variables.tf

# This file defines input variables for the `ec2_instance` module.
# Input variables allow you to parameterize the module, making it reusable and configurable.

# The `ami` variable specifies the Amazon Machine Image (AMI) ID for the EC2 instance.
variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

# The `instance_type` variable specifies the type of EC2 instance to launch (e.g., t2.micro, t3.medium).
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

# The `key_name` variable specifies the name of the SSH key pair to associate with the EC2 instance.
# This allows SSH access to the instance using the specified key pair.
variable "key_name" {
  description = "SSH key name"
  type        = string
}

# The `security_group_id` variable specifies the security group ID to associate with the EC2 instance.
# Security groups control inbound and outbound traffic to the instance.
variable "security_group_id" {
  description = "Security group ID"
  type        = string
}

# The `name` variable specifies the value of the "Name" tag for the EC2 instance.
# Tags are used to identify and organize resources in AWS.
variable "name" {
  description = "Name tag for the EC2 instance"
  type        = string
}







# variable "ami" {
#   description = "AMI ID for the EC2 instance"
#   type        = string
# }

# variable "instance_type" {
#   description = "EC2 instance type"
#   type        = string
# }

# variable "key_name" {
#   description = "SSH key name"
#   type        = string
# }

# variable "security_group_id" {
#   description = "Security group ID"
#   type        = string
# }

# variable "name" {
#   description = "Name tag for the EC2 instance"
#   type = string
# }