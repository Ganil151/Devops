# Create Security Group - SSH Traffic and other ports
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "web-traffic" {
  vpc_id = data.aws_vpc.default.id

  name = "My_Security_Group1"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    "Name" = "My_SG1"
  }
}