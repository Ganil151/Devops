# 16. SNS HTTP/HTTPS Subscription
# Triggering a web hook or external API when a message is published.

resource "aws_sns_topic_subscription" "webhook_target" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "https"
  endpoint  = "https://api.example.com/webhooks/sns"
  
  confirmation_timeout_in_minutes = 3
}
