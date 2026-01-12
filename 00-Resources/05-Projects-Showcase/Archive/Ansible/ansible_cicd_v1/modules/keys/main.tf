resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "cicd_key" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh

  tags = {
    Name = var.key_name
  }
}

resource "local_file" "cicd_key" {
  filename = "${aws_key_pair.cicd_key.key_name}.pem"
  content = tls_private_key.rsa_4096.private_key_pem
  file_permission = 0400

  depends_on = [ tls_private_key.rsa_4096 ]

  provisioner "local-exec" {
    command = "chmod 400 ${local_file.cicd_key.filename}"    
  }
}