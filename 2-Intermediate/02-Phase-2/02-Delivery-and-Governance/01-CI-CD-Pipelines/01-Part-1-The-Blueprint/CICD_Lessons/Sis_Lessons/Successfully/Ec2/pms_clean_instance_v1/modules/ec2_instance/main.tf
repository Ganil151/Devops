# modules\ec2_instance\main.tf

resource "aws_instance" "ec2_instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change

  tags = {
    Name = "PetClinic-Microservice-Apps"
  }
}
