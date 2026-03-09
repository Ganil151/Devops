# 8. Key Stored in SSM Parameter Store
# Store private key in Systems Manager Parameter Store.

resource "tls_private_key" "ssm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssm" {
  key_name   = "ssm-key"
  public_key = tls_private_key.ssm.public_key_openssh

  tags = {
    Name = "SSM-Stored-Key"
  }
}

resource "aws_ssm_parameter" "private_key" {
  name  = "/ec2/keypairs/ssm-key/private"
  type  = "SecureString"
  value = tls_private_key.ssm.private_key_pem

  tags = {
    Name = "EC2-Private-Key"
  }
}
