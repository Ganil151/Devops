# 08. SNS Lambda Subscription
# Triggering a Lambda function when a message is published to the topic.

resource "aws_sns_topic_subscription" "lambda_target" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = var.lambda_function_arn
}
