# 17. IAM Role for Cross-Account Access
# Allowing a user from another AWS account to assume this role.

resource "aws_iam_role" "cross_account_role" {
  name = "cross-account-read-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::SECONDARY_ACCOUNT_ID:root"
        }
      },
    ]
  })
}
