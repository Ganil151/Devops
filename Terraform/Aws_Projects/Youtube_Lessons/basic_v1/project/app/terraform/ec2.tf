

# Security Group
resource "aws_security_group" "ec2_youtube_sg" {
  name        = "nodejs-server-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = "vpc-04291380fa4d7c296"

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TCP"
    from_port   = 3000
    to_port     = 3000
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

#Output
output "ec2_public_ip" {
  value = "ssh -i ~/.ssh/tf_youtube.pem ubuntu@${aws_instance.tf_ec2_instance.public_ip}"
}



# output "ec2_public_ip" {
#   value = aws_instance.tf_ec2_instance.public_ip
# }


# 🛠 If you want to create the key pair via Terraform
# Use a module like this:

# hcl
# Copy
# Edit
# resource "aws_key_pair" "default" {
#   key_name   = "tf_youtube"
#   public_key = file("${path.module}/tf_youtube.pub")
# }
