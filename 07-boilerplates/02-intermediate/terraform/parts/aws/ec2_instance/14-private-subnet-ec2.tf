# 14. Private Subnet Instance (No Public IP)
# Backend instance isolated from the public internet.

resource "aws_instance" "backend_worker" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3.micro"
  subnet_id                   = var.private_subnet_id
  associate_public_ip_address = false # Strict private

  tags = {
    Name = "Private-Backend-Worker"
  }
}
