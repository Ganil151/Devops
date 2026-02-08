# 01. Standard SQS Queue
# Simple queue for decoupled application scaling.

resource "aws_sqs_queue" "standard" {
  name                      = "standard-app-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}
