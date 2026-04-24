#============================================================
#  Key Pair Resources TLS
#============================================================
resource "tls_private_key" "rsa_4096" {
  algorithm = var.key_algorithm
  rsa_bits  = var.rsa_bits
}

#============================================================
#  Key Pair Resources
#============================================================
resource "aws_key_pair" "finishline_public_key" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh

  tags = local.tags

  depends_on = [tls_private_key.rsa_4096]
}

resource "local_file" "finishline_private_key" {
  content         = tls_private_key.rsa_4096.private_key_pem
  filename        = local.private_key_path
  file_permission = var.file_permission

  depends_on = [tls_private_key.rsa_4096]

  provisioner "local-exec" {
    command = "chmod ${var.file_permission} ${local.private_key_path}"
  }

  lifecycle {
    prevent_destroy = false
  }
}
