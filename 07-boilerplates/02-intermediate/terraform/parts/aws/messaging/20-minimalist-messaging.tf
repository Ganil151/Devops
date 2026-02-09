# 20. Minimalist Messaging (SQS)
# The absolute barebones queue definition.

resource "aws_sqs_queue" "minimal" {
  name = "baseline-queue"
}
