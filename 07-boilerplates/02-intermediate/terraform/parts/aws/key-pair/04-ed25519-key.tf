# 4. ED25519 Key Pair
# Modern elliptic curve algorithm for enhanced security.

resource "tls_private_key" "ed25519" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "ed25519" {
  key_name   = "ed25519-key"
  public_key = tls_private_key.ed25519.public_key_openssh

  tags = {
    Name        = "ED25519-Key"
    KeyType     = "ED25519"
  }
}
