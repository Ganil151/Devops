# 1. Basic Key Pair
# Simple SSH key pair with public key string.

resource "aws_key_pair" "basic" {
  key_name   = "basic-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQ..."

  tags = {
    Name = "Basic-Key-Pair"
  }
}
