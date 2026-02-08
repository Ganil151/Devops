# 06. Instance with IAM Instance Profile
# Allows the instance to access AWS services (like S3) without credentials.

resource "aws_instance" "iam_enabled" {
  ami                  = data.aws_ami.amazon_linux_2.id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.s3_access_profile.name

  tags = {
    Name = "S3-Access-Instance"
  }
}

resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3-access-instance-profile"
  role = aws_iam_role.ec2_s3_role.name
}
