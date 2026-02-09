# 07. SNS Email Subscription
# Sending notifications directly to an email address.

resource "aws_sns_topic_subscription" "email_target" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "admin@example.com"
}
# (Note: Email subscriptions require manual confirmation via a link sent to the inbox)
