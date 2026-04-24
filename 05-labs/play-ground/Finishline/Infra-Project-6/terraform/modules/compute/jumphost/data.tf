#============================================================
#  Amazon Linux 2 AMI Lookup
#============================================================
data "aws_ami" "amazon_linux" {
  count = var.ami_id != "" ? 0 : 1

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

#============================================================
#  Amazon Linux 2023 AMI Lookup (Alternative)
#============================================================
data "aws_ami" "amazon_linux_2023" {
  count = var.ami_id != "" ? 0 : 1

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

#============================================================
#  Subnet Lookup for VPC ID
#============================================================
data "aws_subnet" "jumphost" {
  count = var.is_jumphost_enabled && var.subnet_id != "" ? 1 : 0

  id = var.subnet_id
}
