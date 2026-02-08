# 14. SQS Long Polling
# reducing costs and latency by waiting for messages to arrive in the queue.

resource "aws_sqs_queue" "long_polling" {
  name                      = "efficient-polling-queue"
  receive_wait_time_seconds = 20 # Max value for long polling
}
