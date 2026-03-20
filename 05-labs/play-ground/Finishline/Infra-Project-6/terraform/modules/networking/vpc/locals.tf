locals {

  ingress_rules_transform = flatten([
    for rule in var.ingress_rules : [
      for cidr in rule.cidr_blocks : {
        rule_no    = rule.rule_no
        from_port  = rule.from_port
        to_port    = rule.to_port
        protocol   = rule.protocol
        action     = rule.action
        cidr_block = cidr
      }
    ]
  ])

  egress_rules_transform = flatten([
    for rule in var.egress_rules : [
      for cidr in rule.cidr_blocks : {
        rule_no    = rule.rule_no
        from_port  = rule.from_port
        to_port    = rule.to_port
        protocol   = rule.protocol
        action     = rule.action
        cidr_block = cidr
      }
    ]
  ])


  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managed_by
  }
}
