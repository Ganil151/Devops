# -----------------------------------------------------------------------------
# Name: build.pkr.hcl
# Description: Packer configuration for building an AWS AMI with Nginx.
# -----------------------------------------------------------------------------

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# 1. Builder: Define the source VM
source "amazon-ebs" "ubuntu" {
  ami_name      = "my-golden-image-{{timestamp}}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami    = "ami-0c55b159cbfafe1f0" # Ubuntu 22.04
  ssh_username  = "ubuntu"
}

# 2. Build: Define the provisioning steps
build {
  name = "nginx-image"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl enable nginx"
    ]
  }

  provisioner "file" {
    source      = "app.conf"
    destination = "/tmp/app.conf"
  }
}
