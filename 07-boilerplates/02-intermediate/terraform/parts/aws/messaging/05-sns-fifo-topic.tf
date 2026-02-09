# 05. FIFO SNS Topic
# SNS topic with strict ordering and deduplication.

resource "aws_sns_topic" "fifo_alerts" {
  name                        = "transactions.fifo"
  fifo_topic                  = true
  content_based_deduplication = true
}
