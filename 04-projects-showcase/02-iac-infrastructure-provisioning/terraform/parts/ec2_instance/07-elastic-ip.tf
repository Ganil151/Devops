# 07. Instance with Elastic IP
# Static IP that remains the same even if the instance is stopped.

resource "aws_instance" "eip_instance" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
}

resource "aws_eip" "static_ip" {
  instance = aws_instance.eip_instance.id
  domain   = "vpc"

  tags = {
    Name = "Static-IP-Elastic"
  }
}
