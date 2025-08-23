resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow traffic on port 8080 and enable SSH"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["186.6.242.96/32"]
  }
  
  ingress {
    description = "HTTP"  
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "jenkins"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  tags = {
    Name = "jenkins_sg"
  } 
}

resource "aws_security_group" "jenkins_wk_sg" {
  name        = "jenkins_wk_sg"
  description = "Worker Security"
  vpc_id      = var.vpc_id

  
  ingress {
    description = "Worker-SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }
  ingress {
    description = "bash-ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins_wk_sg"
  }
}