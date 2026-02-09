# 03. Windows Server Instance
# Managed Windows instance for enterprise workloads.

data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
}

resource "aws_instance" "windows" {
  ami           = data.aws_ami.windows.id
  instance_type = "t3.medium"

  tags = {
    Name = "Windows-Server-2022"
  }
}
