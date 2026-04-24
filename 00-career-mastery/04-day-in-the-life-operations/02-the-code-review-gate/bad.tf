provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAEXAMPLE123456789" # !!! DANGER: Hardcoded Secret !!!
  secret_key = "mock-secret-key-donot-use"
}

resource "aws_security_group" "messy_sg" {
  name        = "my-sg"
  description = "Open everything"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # !!! DANGER: World-open SSH !!!
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.messy_sg.name]
  
  tags = {
    Name = "My Server"
  }
}
