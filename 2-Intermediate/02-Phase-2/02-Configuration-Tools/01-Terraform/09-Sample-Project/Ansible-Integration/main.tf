# Sample Terraform + Ansible Integration
# Pattern: Push Model (local-exec)

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Create Security Group
resource "aws_security_group" "ansible_sg" {
  name        = "ansible-integration-sg"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Use your IP in production!
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Deploy EC2 Instance
resource "aws_instance" "web_server" {
  ami                    = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04 LTS
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]
  key_name               = "my-ansible-key"

  tags = {
    Name = "Ansible-Managed-Node"
  }

  # 3. Wait for SSH to be ready
  provisioner "remote-exec" {
    inline = ["echo 'System is ready for configuration!'"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.module}/id_rsa") # Local private key
      host        = self.public_ip
    }
  }

  # 4. Trigger Ansible Playbook
  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key id_rsa playbook.yml"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}

output "web_server_url" {
  value = "http://${aws_instance.web_server.public_ip}"
}
