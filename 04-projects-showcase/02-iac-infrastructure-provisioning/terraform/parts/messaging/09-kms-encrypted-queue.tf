# 09. KMS Encrypted SQS Queue
# Securing messages at rest using AWS KMS.

resource "aws_sqs_queue" "encrypted" {
  name                              = "secure-data-queue"
  kms_master_key_id                 = "alias/aws/sqs" # Use default AWS-managed key or custom CMK
  kms_data_key_reuse_period_seconds = 300
}
