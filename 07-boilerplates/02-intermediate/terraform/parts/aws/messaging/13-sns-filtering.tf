# 13. SNS Message Filtering
# ensuring subscribers only receive messages that match specific attributes.

resource "aws_sns_topic_subscription" "filtered_sqs" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.standard.arn

  filter_policy = jsonencode({
    priority = ["high", "critical"]
    category = ["security", "billing"]
  })
}
