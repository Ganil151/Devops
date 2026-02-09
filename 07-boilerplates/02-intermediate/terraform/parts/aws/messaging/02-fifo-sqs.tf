# 02. FIFO SQS Queue
# First-In-First-Out queue for strict ordering and exactly-once processing.

resource "aws_sqs_queue" "fifo" {
  name                        = "orders.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}
