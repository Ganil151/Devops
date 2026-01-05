# This block defines an input variable named "key_name".
# Input variables in Terraform allow you to parameterize your configuration, making it reusable and configurable.

variable "key_name" {
  # The 'description' attribute provides a human-readable explanation of the variable's purpose.
  # In this case, it describes that this variable specifies the name of the SSH key pair.
  description = "Name of the SSH key pair"

  # The 'type' attribute specifies the expected data type for the variable.
  # Here, the type is set to 'string', meaning the value must be a text string.
  type = string
}






# variable "key_name" {
#   description = "Name of the SSH key pair"
#   type        = string
# }
