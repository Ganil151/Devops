# 7. Key Stored in Secrets Manager
# Store private key securely in AWS Secrets Manager.

resource "tls_private_key" "secure" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "secure" {
  key_name   = "secure-key"
  public_key = tls_private_key.secure.public_key_openssh

  tags = {
    Name = "Secure-Key-With-Secrets"
  }
}

resource "aws_secretsmanager_secret" "private_key" {
  name = "ec2-private-key-secure"
}

resource "aws_secretsmanager_secret_version" "private_key" {
  secret_id     = aws_secretsmanager_secret.private_key.id
  secret_string = tls_private_key.secure.private_key_pem
}
