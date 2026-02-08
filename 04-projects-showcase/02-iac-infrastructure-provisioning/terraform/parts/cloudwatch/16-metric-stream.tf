# 16. CloudWatch Metric Stream
# streaming all account metrics to a central location (e.g., Datadog, New Relic) via Kinesis.

resource "aws_cloudwatch_metric_stream" "main" {
  name          = "external-metrics-stream"
  role_arn      = var.stream_role_arn
  firehose_arn  = var.firehose_delivery_stream_arn
  output_format = "json"

  include_filter {
    namespace = "AWS/EC2"
  }
}
