# 15. Root Block Device Configuration
# Customizing the OS disk (size, type, encryption).

resource "aws_instance" "custom_disk" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "Encrypted-Root-Instance"
  }
}
