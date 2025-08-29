resource "aws_instance" "tf_ec2_instance" {
  ami = var.ami
  associate_public_ip_address = var.associate_public_ip_address
  instance_type = var.instance_type
  vpc_security_group_ids = var.vpc_security_group_ids
  key_name = var.key_name
  depends_on =  var.aws_s3_object.tf_s3_object 
  user_data = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change
  tags = var.tags
}