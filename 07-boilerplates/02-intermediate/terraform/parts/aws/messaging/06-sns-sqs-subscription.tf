# 06. SNS to SQS Fan-Out
# Subscribing an SQS queue to an SNS topic for asynchronous processing.

resource "aws_sns_topic_subscription" "sqs_target" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.standard.arn
}
