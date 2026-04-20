locals {

  jumphost_security_group_name        = var.jumphost_security_group_name != "" ? var.jumphost_security_group_name : "${var.project_name}-${var.environment}-jumphost-sg"
  jumphost_security_group_description = "Security group for jumphost in ${var.environment}"

  ingress_rules = [
    {
      description = "Allow SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]

    }
  ]

  common_tags = {
    Name   = "${var.project_name}-${var.environment}-jumphost"
    Module = "jumphost"
  }

}
