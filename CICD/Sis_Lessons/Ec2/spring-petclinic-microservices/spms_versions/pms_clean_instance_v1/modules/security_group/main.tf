resource "aws_security_group" "this" {
  name        = "petclinic-sg"
  description = "Security group for petclinic app"
  vpc_id      = aws_vpc.petclinic_vpc.id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value["description"]
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "petclinic_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "petclinic-vpc"
  }
}