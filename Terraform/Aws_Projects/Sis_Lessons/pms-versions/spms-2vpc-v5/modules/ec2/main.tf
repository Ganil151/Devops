resource "aws_instance" "spms_app" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  user_data                   = var.user_data
  vpc_security_group_ids      = var.security_group_id
  user_data_replace_on_change = var.user_data_replace_on_change

  tags = {
    Name = "${var.project_name}-instance"
  }
}
