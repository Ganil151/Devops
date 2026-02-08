# 02. Ubuntu Server Instance
# Popular choice for web servers and general-purpose projects.

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"

  tags = {
    Name = "Ubuntu-20.04-LTS"
  }
}
