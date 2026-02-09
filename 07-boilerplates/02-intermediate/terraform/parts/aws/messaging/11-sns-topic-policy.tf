# 11. SNS Topic Policy
# allowing other services (like CloudWatch or S3) to publish to the topic.

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "SNS:Publish"
        Effect   = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Resource = aws_sns_topic.alerts.arn
      },
    ]
  })
}
