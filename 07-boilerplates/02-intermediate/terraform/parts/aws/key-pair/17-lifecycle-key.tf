# 17. Key with Lifecycle Rules
# Prevent accidental key deletion.

resource "tls_private_key" "protected" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "protected" {
  key_name   = "protected-key"
  public_key = tls_private_key.protected.public_key_openssh

  lifecycle {
    prevent_destroy = true
    create_before_destroy = true
  }

  tags = {
    Name      = "Protected-Key"
    Protected = "true"
  }
}
