# 12. Conditional Key Creation
# Create key only when needed.

variable "create_key_pair" {
  type    = bool
  default = true
}

resource "tls_private_key" "conditional" {
  count     = var.create_key_pair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "conditional" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = "conditional-key"
  public_key = tls_private_key.conditional[0].public_key_openssh

  tags = {
    Name = "Conditional-Key"
  }
}
