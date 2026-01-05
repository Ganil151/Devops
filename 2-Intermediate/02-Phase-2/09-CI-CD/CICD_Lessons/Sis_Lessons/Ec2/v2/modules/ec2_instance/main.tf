# modules\ec2_instance\main.tf

# This file defines a Terraform module for creating an EC2 instance in AWS.
# Modules in Terraform are reusable components that encapsulate related resources.

# The `aws_instance` resource creates an EC2 instance in AWS.
resource "aws_instance" "this" {
  # The `ami` attribute specifies the Amazon Machine Image (AMI) to use for the EC2 instance.
  # The value is passed as an input variable (`var.ami`) when the module is called.
  ami = var.ami

  # The `instance_type` attribute specifies the type of EC2 instance to launch (e.g., t2.micro, t3.medium).
  # This value is also passed as an input variable (`var.instance_type`).
  instance_type = var.instance_type

  # The `key_name` attribute specifies the name of the key pair to associate with the EC2 instance.
  # This allows SSH access to the instance using the specified key pair.
  # The value is passed as an input variable (`var.key_name`).
  key_name = var.key_name

  # The `vpc_security_group_ids` attribute specifies the security groups to associate with the EC2 instance.
  # Security groups control inbound and outbound traffic to the instance.
  # The value is passed as an input variable (`var.security_group_id`) and wrapped in a list.
  vpc_security_group_ids = [var.security_group_id]

  # The `tags` block allows you to assign metadata (key-value pairs) to the EC2 instance.
  # In this case, a single tag named "Name" is added, which is commonly used to identify the instance in the AWS console.
  # The value of the "Name" tag is passed as an input variable (`var.name`).
  tags = {
    Name = var.name
  }
}








# resource "aws_instance" "this" {
#   ami                    = var.ami
#   instance_type          = var.instance_type
#   key_name               = var.key_name
#   vpc_security_group_ids = [var.security_group_id]

#   tags = {
#     Name = var.name
#   }
# }
