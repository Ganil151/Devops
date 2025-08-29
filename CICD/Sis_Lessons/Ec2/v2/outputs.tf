# This block defines an output variable named "ec2_instance_1_public_ip".
# Outputs in Terraform are used to expose certain values or information after the infrastructure is created.
output "ec2_instance_1_public_ip" {
  # The 'value' attribute specifies the data that this output will return.
  # Here, it retrieves the public IP address of the EC2 instance created by the module named "ec2_instance_1".
  # The value is fetched from the "instance_public_ip" attribute of the "ec2_instance_1" module.
  value       = module.ec2_instance_1.instance_public_ip

  # The 'description' attribute provides a human-readable explanation of what this output represents.
  # In this case, it describes that this output contains the public IP address of Instance 1.
  description = "Public IP of Instance 1"
}

# This block defines another output variable named "ec2_instance_2_public_ip".
output "ec2_instance_2_public_ip" {
  # Similar to the first output, this retrieves the public IP address of the EC2 instance
  # created by the module named "ec2_instance_2".
  value       = module.ec2_instance_2.instance_public_ip

  # The description clarifies that this output contains the public IP address of Instance 2.
  description = "Public IP of Instance 2"
}

# This block defines a third output variable named "ec2_instance_3_public_ip".
output "ec2_instance_3_public_ip" {
  # This retrieves the public IP address of the EC2 instance created by the module named "ec2_instance_3".
  value       = module.ec2_instance_3.instance_public_ip

  # The description explains that this output contains the public IP address of Instance 3.
  description = "Public IP of Instance 3"
}