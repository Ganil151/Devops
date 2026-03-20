#============================================================
#  Security Group 
#============================================================
resource "aws_security_group" "finishline_sg" {
  name        = local.security_group_name
  description = local.security_group_description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.all_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks

    }
  }

  dynamic "egress" {
    for_each = local.egress_rules_transformed
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}
