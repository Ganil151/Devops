resource "aws_instance" "petclinic_ms" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  user_data                   = file("${path.module}/script.sh")
  user_data_replace_on_change = var.user_data_replace_on_change
  vpc_security_group_ids      = var.vpc_security_group_ids

  tags = {
    Name = var.name
  }
}
