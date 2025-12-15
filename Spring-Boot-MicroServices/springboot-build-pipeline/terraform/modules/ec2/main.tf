resource "aws_instance" "this" {
  ami                    = "ami-0ecb62995f68bb549"
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.subnet_id

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
    encrypted   = true
  }

  user_data = var.user_data

  tags = {
    Name = var.name
    Type = var.server_type
  }
}
