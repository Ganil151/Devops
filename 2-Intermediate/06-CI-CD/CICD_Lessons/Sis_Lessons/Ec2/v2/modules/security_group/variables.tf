# This file defines input variables for the `security_group` module.
# Input variables allow you to parameterize the module, making it reusable and configurable.

# The `name` variable specifies the name of the security group.
variable "name" {
  # The 'description' attribute provides a human-readable explanation of the variable's purpose.
  # In this case, it describes that this variable specifies the name of the security group.
  description = "Name of the security group"

  # The 'type' attribute specifies the expected data type for the variable.
  # Here, the type is set to `string`, meaning the value must be a text string.
  type = string
}

# The `ingress_rules` variable defines a list of ingress rules for the security group.
variable "ingress_rules" {
  # The 'description' attribute explains the purpose of the variable.
  # In this case, it describes that this variable specifies a list of ingress rules for the security group.
  description = "List of ingress rules for the security group"

  # The 'type' attribute specifies the structure of the variable.
  # It is defined as a list of objects, where each object represents an ingress rule with specific attributes.
  type = list(object({
    # The `from_port` attribute specifies the starting port for the rule (e.g., 22 for SSH).
    from_port = number

    # The `to_port` attribute specifies the ending port for the rule (e.g., 22 for SSH).
    to_port = number

    # The `protocol` attribute specifies the protocol for the rule (e.g., "tcp", "udp", "icmp").
    protocol = string

    # The `source_security_group_id` attribute specifies the ID of another security group that is allowed to connect.
    # This attribute is optional, so it may or may not be provided.
    source_security_group_id = optional(string)

    # The `cidr_blocks` attribute specifies the IP address ranges that are allowed for inbound traffic.
    # This attribute is optional, so it may or may not be provided.
    cidr_blocks = optional(list(string))
  }))

  # The 'default' attribute specifies a default value for the variable.
  # If no value is provided when calling the module, an empty list (`[]`) will be used.
  default = []
}









# # modules\security_group\variables.tf
# variable "name" {
#   description = "Name of the security group"
#   type        = string
# }

# variable "ingress_rules" {
#   description = "List of ingress rules for the security group"
#   type = list(object({
#     from_port                = number
#     to_port                  = number
#     protocol                 = string
#     source_security_group_id = optional(string)
#     cidr_blocks              = optional(list(string))  
#   }))
#   default = []
# }
