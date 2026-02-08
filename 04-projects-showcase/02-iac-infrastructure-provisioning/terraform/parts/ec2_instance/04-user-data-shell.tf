# 04. Instance with User Data (Shell Script)
# Boots with a pre-installed web server (Nginx).

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install nginx1 -y
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Welcome to my Antigravity Web Server</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "Nginx-Web-Server"
  }
}
