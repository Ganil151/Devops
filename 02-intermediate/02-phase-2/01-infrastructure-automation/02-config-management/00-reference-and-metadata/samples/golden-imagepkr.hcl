# Topic: Immutable Infrastructure (Baking)
# Description: Builds a hardened Ubuntu AMI with Nginx pre-installed.

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu_nginx" {
  ami_name      = "hardened-web-v{{timestamp}}"
  instance_type = "t3.micro"
  region        = "us-east-1"
  
  # 🛡️ Architecture: Search for the official base image
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.ubuntu_nginx"]

  # 🚀 Layer 1: System Hardening
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl enable nginx"
    ]
  }

  # 🚀 Layer 2: Corporate Security Tags
  post-processor "manifest" {
    output = "manifest.json"
  }
}
