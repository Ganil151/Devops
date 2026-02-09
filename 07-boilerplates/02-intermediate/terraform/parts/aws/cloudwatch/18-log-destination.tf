# 18. CloudWatch Log Destination
# Cross-account log sharing setup (Destination Side).

resource "aws_cloudwatch_log_destination" "shared" {
  name       = "central-logging-destination"
  role_arn   = var.logging_role_arn
  target_arn = var.kinesis_stream_arn

  access_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "logs:PutSubscriptionFilter"
        Effect   = "Allow"
        Principal = { AWS = "*" }
        Resource = "arn:aws:logs:us-east-1:ACCOUNT_ID:destination:central-logging-destination"
      }
    ]
  })
}
