resource "aws_instance" "this" {
  ami = var.ami
  instance_type = var.instance_type
  user_data = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change
  subnet_id = var.subnet_id
  key_name = var.key_name  
  vpc_security_group_ids = var.vpc_security_group_ids  
}