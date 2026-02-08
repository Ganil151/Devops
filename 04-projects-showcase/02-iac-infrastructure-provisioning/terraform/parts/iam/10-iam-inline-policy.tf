# 10. IAM Inline Policy
# A policy embedded directly into a user, group, or role (non-reusable).

resource "aws_iam_user_policy" "lb_ro" {
  name = "test"
  user = aws_iam_user.standard_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
