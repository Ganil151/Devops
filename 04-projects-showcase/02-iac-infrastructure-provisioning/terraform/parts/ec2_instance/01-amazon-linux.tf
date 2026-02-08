# 01. Basic Amazon Linux 2 Instance
# Standard entry-level EC2 instance.

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "amazon_linux" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  tags = {
    Name = "Basic-Amazon-Linux"
  }
}
