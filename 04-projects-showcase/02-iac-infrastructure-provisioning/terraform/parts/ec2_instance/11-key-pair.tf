# 11. Instance with Key Pair
# Secure SSH access using a provisioned public key.

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6..." # Replace with actual key
}

resource "aws_instance" "secure_ssh" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer.key_name

  tags = {
    Name = "SSH-Enabled-Worker"
  }
}
