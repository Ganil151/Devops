# 05. IAM Role for EC2
# Allowing an EC2 instance to assume a role.

resource "aws_iam_role" "ec2_role" {
  name = "ec2_example_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_example_profile"
  role = aws_iam_role.ec2_role.name
}
# (See parts/ec2_instance/06-iam-role-instance.tf for usage)
