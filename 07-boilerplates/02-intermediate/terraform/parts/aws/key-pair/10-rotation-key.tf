# 10. Key Rotation Pattern
# Implement key rotation with versioning.

variable "key_version" {
  default = "v1"
}

resource "tls_private_key" "rotated" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "rotated" {
  key_name   = "rotated-key-${var.key_version}"
  public_key = tls_private_key.rotated.public_key_openssh

  tags = {
    Name       = "Rotated-Key"
    Version    = var.key_version
    RotatedAt  = timestamp()
  }
}
