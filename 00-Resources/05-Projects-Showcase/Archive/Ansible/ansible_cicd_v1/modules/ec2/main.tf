resource "aws_instance" "cicd-server" {
  ami = var.ami
  key_name = var.key_name
  user_data = var.user_data
  subnet_id = var.subnet_id
  instance_type = var.instance_type
  user_data_replace_on_change = var.user_data_replace_on_change

  tags = {
    Name = "${var.project_name}"
  }    
}