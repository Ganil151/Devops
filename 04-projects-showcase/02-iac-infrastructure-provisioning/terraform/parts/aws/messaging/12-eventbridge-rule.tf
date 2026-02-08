# 12. EventBridge Rule for SQS
# Triggering an SQS queue based on a system event (e.g., EC2 State Change).

resource "aws_cloudwatch_event_rule" "ec2_state" {
  name        = "capture-ec2-state-change"
  description = "Capture all EC2 state changes"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
  })
}

resource "aws_cloudwatch_event_target" "sqs" {
  rule      = aws_cloudwatch_event_rule.ec2_state.name
  target_id = "SendToSQS"
  arn       = aws_sqs_queue.standard.arn
}
