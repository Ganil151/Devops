# 03. IAM Managed Policy (JSON)
# A reusable policy defined using a JSON-encoded string.

resource "aws_iam_policy" "s3_read_only" {
  name        = "S3ReadOnlySpecificBucket"
  path        = "/"
  description = "Allows read-only access to a specific s3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:Get*",
          "s3:List*",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::my-special-bucket/*"
      },
    ]
  })
}
