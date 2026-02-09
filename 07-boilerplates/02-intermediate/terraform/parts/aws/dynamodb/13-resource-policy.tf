# 13. Resource-Based Policy for DynamoDB
# Granting cross-account access or specific service permissions.

resource "aws_dynamodb_resource_policy" "example" {
  resource_arn = aws_dynamodb_table.basic_ondemand.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "dynamodb:GetItem"
        Effect   = "Allow"
        Principal = {
          AWS = "arn:aws:iam::SECONDARY_ACCOUNT_ID:root"
        }
        Resource = aws_dynamodb_table.basic_ondemand.arn
      }
    ]
  })
}
