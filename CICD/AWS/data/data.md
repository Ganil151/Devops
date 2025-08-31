# This block defines a data source to fetch the most recent Amazon Linux AMI from AWS.
data "aws_ami" Block:
This block fetches information about an AMI (Amazon Machine Image) from AWS.
The most_recent = true ensures that the latest available AMI matching the filters is selected.
The owners field specifies that the AMI must belong to Amazon (amazon).
The filter blocks further refine the selection:
The first filter matches AMIs by name using a pattern provided via the ami_name_pattern variable.
The second filter ensures the AMI has the specified virtualization type (hvm).
Variables (variable.tf):
Variables allow dynamic configuration of the Terraform code.
ami_name_pattern and ami_virtualization_type are used to define the AMI's name and virtualization type dynamically.
Values (terraform.tfvars):
These provide concrete values for the variables defined in variable.tf.
For example, ami_name_pattern is set to match Amazon Linux 2 AMIs with a specific kernel and architecture.
Module (main.tf):
The module "master_instance" block creates an EC2 instance using the fetched AMI and other configurations.
It uses outputs from other modules (e.g., vpc, security_group) to configure the instance.
The user_data script is executed during instance launch to perform initial setup.

```terraform
data "aws_ami" "amazon-linux" {
  # Ensures that the most recent AMI is selected.
  most_recent = true

  # Specifies the owner of the AMI. In this case, it is owned by Amazon (canonical).
  owners      = ["amazon"] # Canonical

  # Filters are used to narrow down the AMIs based on specific criteria.
  filter {
    # Filters AMIs by their name using a pattern defined in the variable `ami_name_pattern`.
    name   = "name"
    values = [var.ami_name_pattern] # Uses the variable `ami_name_pattern` for dynamic filtering.
  }

  filter {
    # Filters AMIs by their virtualization type, which is defined in the variable `ami_virtualization_type`.
    name   = "virtualization-type"
    values = [var.ami_virtualization_type] # Uses the variable `ami_virtualization_type` for dynamic filtering.
  }
}
```
# Below are the variable definitions used in the Terraform configuration.

# variable.tf
```terraform
variable "ami_name_pattern" {
  description = "The name pattern of the AMI to use for the EC2 instance" # Describes the purpose of the variable.
  type        = string # Specifies that the variable is of type string.
}

variable "ami_virtualization_type" {
  description = "The virtualization type of the AMI to use for the EC2 instance" # Describes the purpose of the variable.
  type        = string # Specifies that the variable is of type string.
}
```

# terraform.tfvars
# These are the actual values assigned to the variables for the Terraform deployment.
```terraform
ami_name_pattern            = "amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2" # Matches Amazon Linux 2 AMIs with a specific kernel version and architecture.
ami_virtualization_type     = "hvm" # Specifies the hardware virtualization type.
```

# main.tf
# This module creates an EC2 instance using the AMI fetched above and other configurations.
```terraform
module "master_instance" {
  source                      = "../modules/ec2" # Specifies the location of the EC2 module.
  
  # Uses the ID of the AMI fetched by the `aws_ami` data source.
  ami                         = data.aws_ami.amazon-linux.id
  
  # Specifies the key pair name for SSH access to the EC2 instance.
  key_name                    = var.key_name
  
  # Sets the project name for the EC2 instance, appending "-master-v2" to the base project name.
  project_name                = "${var.project_name}-master-v2"
  
  # Specifies the instance type (e.g., t2.micro) for the EC2 instance.
  instance_type               = var.instance_type
  
  # Selects the first public subnet ID from the VPC module for the EC2 instance.
  subnet_id                   = element(module.vpc.public_subnet_ids, 0)
  
  # Specifies the user data script to run on the EC2 instance during launch.
  user_data                   = file("${path.module}/scripts/terraform_setup.sh")
  
  # Determines whether the user data script should be replaced when changes are made.
  user_data_replace_on_change = var.user_data_replace_on_change
  
  # Assigns the security group ID from the security group module to the EC2 instance.
  security_group_ids          = [module.security_group.security_group_id]
}
```