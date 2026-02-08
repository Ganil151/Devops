# 15. SNS SMS Subscription
# sending text message notifications to a mobile phone.

resource "aws_sns_topic_subscription" "sms_target" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "sms"
  endpoint  = "+12345678901"
}
