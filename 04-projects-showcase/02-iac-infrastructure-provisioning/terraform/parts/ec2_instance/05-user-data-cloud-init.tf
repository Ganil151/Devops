# 05. Instance with User Data (Cloud-init)
# Using YAML-based cloud-init for complex configurations.

resource "aws_instance" "cloud_init" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  user_data = yamlencode({
    package_update  = true
    package_upgrade = true
    packages        = ["docker.io", "git"]
    runcmd = [
      ["systemctl", "start", "docker"],
      ["systemctl", "enable", "docker"],
      ["usermod", "-aG", "docker", "ubuntu"],
    ]
  })

  tags = {
    Name = "Docker-Ready-Instance"
  }
}
# (Note: Cloud-init support varies by AMI)
