# modules\key_pair\main.tf
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "key_pair" {
  depends_on = [tls_private_key.rsa_4096] 
  key_name   = "sis_key_pair"
  public_key = tls_private_key.rsa_4096.public_key_openssh
}

resource "local_file" "private_key" {
  depends_on = [tls_private_key.rsa_4096] 
  content    = tls_private_key.rsa_4096.private_key_pem
  filename   = "sis_key_pair.pem"
  file_permission = "0400"
}