# Terraform & Cloud-Init Example

provider "aws" {
  region = "us-east-1"
}

# 1. Defining the Cloud-Init configuration via templatefile
# This allows us to pass Terraform variables into our YAML config
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04
  instance_type = "t3.micro"

  user_data = templatefile("${path.module}/cloud-config.yaml", {
    hostname    = "web-prod-01"
    admin_user  = "sre_admin"
    web_message = "Hello from Terraform + Cloud-Init!"
  })

  tags = {
    Name = "Cloud-Init-Demo"
  }
}

output "instance_ip" {
  value = aws_instance.web_server.public_ip
}
