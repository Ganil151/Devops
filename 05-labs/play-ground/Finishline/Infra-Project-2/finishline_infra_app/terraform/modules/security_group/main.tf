#========================================================
#  Security Group Project Modules
#========================================================
resource "aws_security_group" "finishline_sg" {
  name        = var.security_group_name
  description = "Security group for finishline application"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port       = ingress.value["from_port"]
      to_port         = ingress.value["to_port"]
      protocol        = ingress.value["protocol"]
      cidr_blocks     = ingress.value["cidr_blocks"]
      description     = ingress.value["description"]
    }
  }

  # EKS worker node communication
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = true
    description = "EKS worker node communication"
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port       = egress.value["from_port"]
      to_port         = egress.value["to_port"]
      protocol        = egress.value["protocol"]
      cidr_blocks     = egress.value["cidr_blocks"]
      description     = egress.value["description"]
    }
  }

  tags = local.sg_tags 
  
}