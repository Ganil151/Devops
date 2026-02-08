# 01. Default Subnet
# Re-using a default subnet from the AWS-provided Default VPC.

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "Default Subnet for us-east-1a"
  }
}
