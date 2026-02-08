# 19. S3 Bucket with Event Notifications
# Triggers external services like Lambda or SQS when objects are created.

resource "aws_s3_bucket" "trigger_bucket" {
  bucket = "event-trigger-bucket-${random_id.bucket_id.hex}"
}

resource "aws_sqs_queue" "s3_events" {
  name = "s3-event-notification-queue"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.trigger_bucket.id

  queue {
    queue_arn     = aws_sqs_queue.s3_events.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".log"
  }
}
# (SQS Policy allowing S3 to send messages would be needed)
