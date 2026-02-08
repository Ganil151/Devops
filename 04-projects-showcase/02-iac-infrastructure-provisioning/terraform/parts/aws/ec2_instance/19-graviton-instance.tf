# 19. ARM-based Instance (Graviton - T4g)
# High price-performance ratio using AWS Graviton2 processors.

data "aws_ami" "arm_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-arm64-gp2"]
  }
}

resource "aws_instance" "graviton" {
  ami           = data.aws_ami.arm_linux.id
  instance_type = "t4g.small"

  tags = {
    Name = "Graviton-ARM-Worker"
  }
}
