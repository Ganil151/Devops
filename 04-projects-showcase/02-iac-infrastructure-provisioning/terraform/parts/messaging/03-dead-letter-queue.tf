# 03. Dead Letter Queue (DLQ) Configuration
# Handling failed messages by moving them to a secondary queue for inspection.

resource "aws_sqs_queue" "dlq" {
  name = "app-dead-letter-queue"
}

resource "aws_sqs_queue" "main_with_dlq" {
  name = "app-main-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5 # Move to DLQ after 5 failed attempts
  })
}
