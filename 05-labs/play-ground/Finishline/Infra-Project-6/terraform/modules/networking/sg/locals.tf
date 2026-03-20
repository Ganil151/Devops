locals {
  security_group_name        = var.security_group_name != "" ? var.security_group_name : "${var.project_name}-sg"
  security_group_description = var.security_group_description != "" ? var.security_group_description : "Security group for ${var.project_name}"

  ingress_rules_transformed = [
    for rule in var.ingress_rules : {
      description = rule.description
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      cidr_blocks = rule.cidr_blocks
    }
  ]
    
  eks_ingress_rules_transformed = [
    for rule in var.eks_ingress_rules : {
      description = rule.description
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      cidr_blocks = rule.cidr_blocks
    }

  ]
  # Combine standard and EKS ingress rules
  all_ingress_rules = concat(local.ingress_rules_transformed, local.eks_ingress_rules_transformed)

  egress_rules_transformed = length(var.egress_rules) > 0 ? [
    for rule in var.egress_rules : {
      description = rule.description
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      cidr_blocks = rule.cidr_blocks
    }
  ] : [{
    description = "Allow all egress traffic"
    from_port = 0 
    to_port = 0 
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }]

  common_tags = {
    Name = "${var.project_name}-sg"
    Module = "sg"
  }

}
