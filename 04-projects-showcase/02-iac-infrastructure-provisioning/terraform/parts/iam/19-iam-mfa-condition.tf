# 19. IAM Role with MFA Condition
# Requiring Multi-Factor Authentication for sensitive actions.

resource "aws_iam_policy" "sensitive_access" {
  name = "SensitiveS3AccessWithMFA"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "s3:DeleteBucket"
        Effect = "Allow"
        Resource = "*"
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      },
    ]
  })
}
