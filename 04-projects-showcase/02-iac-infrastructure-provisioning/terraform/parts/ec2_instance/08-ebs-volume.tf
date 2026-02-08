# 08. Instance with Extra EBS Volume
# Adding persistent storage blocks to the instance.

resource "aws_instance" "app_with_storage" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  tags = {
    Name = "Stored-App-Instance"
  }
}

resource "aws_ebs_volume" "data_volume" {
  availability_zone = aws_instance.app_with_storage.availability_zone
  size              = 50
  type              = "gp3"

  tags = {
    Name = "Data-Storage-Volume"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.data_volume.id
  instance_id = aws_instance.app_with_storage.id
}
