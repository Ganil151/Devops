# 16. IAM Role with Permissions Boundary
# Restricting the maximum permissions that a role can have.

resource "aws_iam_role" "limited_role" {
  name                 = "limited-admin-role"
  permissions_boundary = aws_iam_policy.boundary.arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      },
    ]
  })
}

resource "aws_iam_policy" "boundary" {
  name = "max-permission-boundary"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "ec2:*"
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
