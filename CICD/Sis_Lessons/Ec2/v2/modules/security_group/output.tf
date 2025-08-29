# This block defines an output variable named "security_group_id".
# Outputs in Terraform are used to expose certain values or information after the infrastructure is created.

output "security_group_id" {
  # The 'value' attribute specifies the data that this output will return.
  # Here, it retrieves the ID of the security group created by the `aws_security_group.allow_ssh_http` resource.
  # The `id` attribute of the `aws_security_group` resource contains the unique identifier for the security group.
  value = aws_security_group.allow_ssh_http.id

  # (Optional) A description can be added to provide context or documentation for the output.
  # For example:
  # description = "The ID of the security group created by the module."
}





# output "security_group_id" {
#   value = aws_security_group.allow_ssh_http.id
# }
