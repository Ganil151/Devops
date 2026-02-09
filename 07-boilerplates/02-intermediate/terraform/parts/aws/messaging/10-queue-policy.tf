# 10. SQS Queue Policy
# controlling which services or accounts can send/receive messages.

resource "aws_sqs_queue_policy" "example" {
  queue_url = aws_sqs_queue.standard.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sqs:SendMessage"
        Effect   = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Resource = aws_sqs_queue.standard.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.alerts.arn
          }
        }
      },
    ]
  })
}
