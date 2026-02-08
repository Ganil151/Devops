# Node Groups configuration (Example for separation)
# In terraform-aws-modules, node groups are defined in main.tf inside the module block usually.
# But you can define separate managed node groups resource if NOT using the module block for node groups.

# Resource "aws_eks_node_group" "example" { ... } if you wanted.
# For now, this file is a placeholder for future custom node group definitions.
