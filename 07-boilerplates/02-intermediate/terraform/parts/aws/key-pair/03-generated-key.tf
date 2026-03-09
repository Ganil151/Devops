# 3. Generated Key Pair
# Generate SSH key pair using TLS provider.

resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  key_name   = "generated-key"
  public_key = tls_private_key.generated.public_key_openssh

  tags = {
    Name = "Generated-Key"
  }
}

resource "local_file" "private_key" {
  content         = tls_private_key.generated.private_key_pem
  filename        = "${path.module}/generated-key.pem"
  file_permission = "0400"
}
