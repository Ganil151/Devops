variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster-name" {
  description = "Legacy cluster name (use cluster_name instead)"
  type        = string
  default     = ""
}
variable "cidr-block" {}
variable "vpc-name" {}
variable "env" {}
variable "igw-name" {}
variable "pub-subnet-count" {}
variable "pub-cidr-block" {
  type = list(string)
}
variable "pub-availability-zone" {
  type = list(string)
}
variable "pub-sub-name" {}
variable "pri-subnet-count" {}
variable "pri-cidr-block" {
  type = list(string)
}
variable "pri-availability-zone" {
  type = list(string)
}
variable "pri-sub-name" {}
variable "public-rt-name" {}
variable "private-rt-name" {}
variable "eip-name" {}
variable "ngw-name" {}
# variable "eks-sg" {}

#IAM
variable "is_eks_role_enabled" {
  description = "Whether to create the EKS cluster role"
  type        = bool
  default     = false
}

variable "is_eks_nodegroup_role_enabled" {
  description = "Whether to create the EKS node group role"
  type        = bool
  default     = false
}

# EKS
variable "is_eks_cluster_enabled" {
  description = "Whether to create the EKS cluster"
  type        = bool
  default     = false
}

# Security Group
variable "eks-sg" {
  description = "Name of the EKS cluster security group"
  type        = string
  default     = ""
}

# Legacy variable names for backward compatibility
variable "is-eks-cluster-enabled" {
  type    = bool
  default = false
}
variable "cluster-version" {}
variable "endpoint-private-access" {}
variable "endpoint-public-access" {}
variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
}
variable "ondemand_instance_types" {}
variable "spot_instance_types" {}
variable "desired_capacity_on_demand" {}
variable "min_capacity_on_demand" {}
variable "max_capacity_on_demand" {}
variable "desired_capacity_spot" {}
variable "min_capacity_spot" {}
variable "max_capacity_spot" {}

# EC2 Jump Server
variable "ami_id" {}
variable "instance_type" {}
