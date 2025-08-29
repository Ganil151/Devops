# This block defines an output variable named "key_name".
# Outputs in Terraform are used to expose certain values or information after the infrastructure is created.

output "key_name" {
  # The 'value' attribute specifies the data that this output will return.
  # Here, it retrieves the name of the AWS key pair created by the `aws_key_pair.key_pair` resource.
  # The `key_name` attribute of the `aws_key_pair` resource contains the name of the key pair.
  value = aws_key_pair.key_pair.key_name

  # (Optional) A description can be added to provide context or documentation for the output.
  # For example:
  # description = "The name of the AWS key pair used for SSH access."
}










# output "key_name" {
#   value = aws_key_pair.key_pair.key_name
# }