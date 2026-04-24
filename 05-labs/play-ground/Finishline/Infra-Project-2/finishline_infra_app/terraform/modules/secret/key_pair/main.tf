#===========================================================
#  Key Pair Module - Main
#===========================================================
resource "tls_private_key" "rsa_4096" {
  algorithm = var.key_algorithm
  rsa_bits  = var.rsa_bits
}

resource "aws_key_pair" "finishline_key" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh

  depends_on = [tls_private_key.rsa_4096]

  tags = local.tags
}

resource "local_file" "private_key" {
  content         = tls_private_key.rsa_4096.private_key_pem
  filename        = local.key_pair_private_key_pathname
  file_permission = "0400"
}
