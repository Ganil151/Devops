# This block defines an output variable named "instance_public_ip".
# Outputs in Terraform are used to expose certain values or information after the infrastructure is created.
output "instance_public_ip" {
  # The 'value' attribute specifies the data that this output will return.
  # Here, it retrieves the public IP address of the EC2 instance created by the `aws_instance.this` resource.
  # The `public_ip` attribute of the `aws_instance` resource contains the public IP address assigned to the instance.
  value = aws_instance.this.public_ip

  # (Optional) A description can be added to provide context or documentation for the output.
  # For example:
  # description = "The public IP address of the EC2 instance."
}








# output "instance_public_ip" {
#   value = aws_instance.this.public_ip
# }