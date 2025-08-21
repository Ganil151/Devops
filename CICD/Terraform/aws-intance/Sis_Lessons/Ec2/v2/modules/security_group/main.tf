# This file defines a Terraform module for creating a security group in AWS.
# Security groups act as virtual firewalls to control inbound and outbound traffic for AWS resources.

# The `aws_security_group` resource creates a custom security group.
resource "aws_security_group" "allow_ssh_http" {
  # The `name` attribute specifies the name of the security group.
  # The value is passed as an input variable (`var.name`) when the module is called.
  name = var.name

  # The `description` attribute provides a description of the security group's purpose.
  description = "Custom security group for SSH access"

  # Default egress rule (allows all outbound traffic)
  egress {
    # The `from_port` and `to_port` attributes specify the range of ports for the rule.
    # A value of `0` allows all ports.
    from_port = 0
    to_port   = 0

    # The `protocol` attribute specifies the protocol for the rule.
    # A value of `-1` allows all protocols (TCP, UDP, ICMP, etc.).
    protocol = "-1"

    # The `cidr_blocks` attribute specifies the IP address ranges that are allowed for outbound traffic.
    # `"0.0.0.0/0"` allows all IP addresses.
    cidr_blocks = ["0.0.0.0/0"]
  }

  # The `tags` block adds metadata (key-value pairs) to the security group.
  # In this case, a single tag named "Name" is added, which is commonly used to identify the resource in AWS.
  tags = {
    Name = var.name
  }
}

# The `aws_security_group_rule` resource dynamically creates ingress rules for the security group.
# These rules control inbound traffic based on the configuration provided in the `var.ingress_rules` variable.
resource "aws_security_group_rule" "ingress_rules" {
  # The `count` attribute dynamically determines how many ingress rules to create.
  # It uses the length of the `var.ingress_rules` list to iterate over each rule.
  count = length(var.ingress_rules)

  # The `type` attribute specifies the type of rule. For ingress rules, the value is `"ingress"`.
  type = "ingress"

  # The `security_group_id` attribute specifies the ID of the security group to which the rule will be applied.
  # It references the `id` of the `aws_security_group.allow_ssh_http` resource created earlier.
  security_group_id = aws_security_group.allow_ssh_http.id

  # The `from_port` attribute specifies the starting port for the rule.
  # It retrieves the value from the `from_port` field of the current rule in the `var.ingress_rules` list.
  from_port = var.ingress_rules[count.index].from_port

  # The `to_port` attribute specifies the ending port for the rule.
  # It retrieves the value from the `to_port` field of the current rule in the `var.ingress_rules` list.
  to_port = var.ingress_rules[count.index].to_port

  # The `protocol` attribute specifies the protocol for the rule (e.g., "tcp", "udp", "icmp").
  # It retrieves the value from the `protocol` field of the current rule in the `var.ingress_rules` list.
  protocol = var.ingress_rules[count.index].protocol

  # The `source_security_group_id` attribute specifies the ID of another security group that is allowed to connect.
  # It uses the `lookup` function to retrieve the value from the `source_security_group_id` field if it exists.
  # If the field is not present, it defaults to `null`.
  source_security_group_id = lookup(var.ingress_rules[count.index], "source_security_group_id", null)

  # The `cidr_blocks` attribute specifies the IP address ranges that are allowed for inbound traffic.
  # It uses the `lookup` function to retrieve the value from the `cidr_blocks` field if it exists.
  # If the field is not present, it defaults to an empty list (`[]`).
  cidr_blocks = lookup(var.ingress_rules[count.index], "cidr_blocks", [])
}

















# # modules\security_group\main.tf

# resource "aws_security_group" "allow_ssh_http" {
#   name        = var.name
#   description = "Custom security group for SSH access"

#   # Default egress rule (allows all outbound traffic)
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = var.name
#   }
# }

# # Add custom ingress rules dynamically
# resource "aws_security_group_rule" "ingress_rules" {
#   count             = length(var.ingress_rules)
#   type              = "ingress"
#   security_group_id = aws_security_group.allow_ssh_http.id

#   from_port                = var.ingress_rules[count.index].from_port
#   to_port                  = var.ingress_rules[count.index].to_port
#   protocol                 = var.ingress_rules[count.index].protocol
#   source_security_group_id = lookup(var.ingress_rules[count.index], "source_security_group_id", null)
#   cidr_blocks = lookup(var.ingress_rules[count.index], "cidr_blocks", [])
# }
