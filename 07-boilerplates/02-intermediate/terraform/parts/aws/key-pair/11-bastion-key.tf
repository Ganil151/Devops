# 11. Bastion Host Key Pair
# Dedicated key for bastion/jump host access.

resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion" {
  key_name   = "bastion-host-key"
  public_key = tls_private_key.bastion.public_key_openssh

  tags = {
    Name    = "Bastion-Host-Key"
    Purpose = "SSH-Jump-Host"
    Access  = "Restricted"
  }
}

output "bastion_key_name" {
  value = aws_key_pair.bastion.key_name
}
