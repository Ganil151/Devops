# 04. Standard SNS Topic
# Simple Pub/Sub topic for broadcasting messages to multiple subscribers.

resource "aws_sns_topic" "alerts" {
  name = "system-alerts-topic"
}
