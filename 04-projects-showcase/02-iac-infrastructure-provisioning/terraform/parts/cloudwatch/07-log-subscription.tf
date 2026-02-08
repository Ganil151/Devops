# 07. CloudWatch Logs Subscription Filter
# streaming logs to an S3 bucket or Kinesis for long-term storage or analysis.

resource "aws_cloudwatch_log_subscription_filter" "to_kinesis" {
  name            = "logs-to-kinesis"
  log_group_name  = aws_cloudwatch_log_group.standard.name
  filter_pattern  = "" # All logs
  destination_arn = var.kinesis_stream_arn
  role_arn        = var.iam_role_arn
}
