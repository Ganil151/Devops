resource "aws_instance" "jenkins-server" {
  ami                         = var.ami
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [var.vpc_security_group_id]
  user_data = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change

  tags = {
    Name = "${var.project_name}"
  }

}
