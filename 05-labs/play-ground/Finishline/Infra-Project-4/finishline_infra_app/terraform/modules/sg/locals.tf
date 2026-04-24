locals {

  security_group_name        = var.security_group_name != "" ? var.security_group_name : "${var.project_name}-${var.environment}-sg"
  security_group_description = "Security group for ${var.project_name} in ${var.environment}"

  # Standard ingress rules
  ingress_rules_transformed = [
    for rule in var.ingress_rules : {
      description = rule.description
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      cidr_blocks = rule.cidr_blocks
    }
  ]

  # EKS-specific ingress rules
  eks_ingress_rules = var.enable_eks_rules ? [
    {
      description = "EKS Kubernetes API"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [var.vpc_id] # Will be replaced with security group in main.tf
    },
    {
      description = "Kubelet API from worker nodes"
      from_port   = 10250
      to_port     = 10250
      protocol    = "tcp"
      cidr_blocks = [var.vpc_id] # Will be replaced in main.tf
    },
    {
      description = "NodePort services"
      from_port   = 30000
      to_port     = 32767
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ] : []

  # Combine standard and EKS rules
  all_ingress_rules = concat(local.ingress_rules_transformed, local.eks_ingress_rules)

  egress_rules_transformed = length(var.egress_rules) > 0 ? [
    for rule in var.egress_rules : {
      description = rule.description
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      cidr_blocks = rule.cidr_blocks
    }
    ] : [{
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }]

  common_tags = {
    Name   = "${var.project_name}-${var.environment}-sg"
    Module = "sg"
  }

  project_name = "${var.project_name}-${var.environment}"

}
