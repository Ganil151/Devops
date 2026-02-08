# 13. VPC with Security Groups
# Resource-level traffic filtering (stateful).

resource "aws_vpc" "sg_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.sg_vpc.id

  ingress {
    description      = "HTTPS from anywhere"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-Security-Group"
  }
}
