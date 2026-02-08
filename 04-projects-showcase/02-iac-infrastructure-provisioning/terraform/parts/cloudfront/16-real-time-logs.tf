# 16. CloudFront Real-time Logs (Kinesis)
# streaming access logs to Kinesis Data Streams for near-instant analysis.

resource "aws_cloudfront_realtime_log_config" "example" {
  name          = "realtime-log-config"
  sampling_rate = 100
  fields        = ["timestamp", "c-ip", "time-to-first-byte", "sc-status"]

  endpoint {
    stream_type = "Kinesis"

    kinesis_stream_config {
      role_arn   = var.logging_role_arn
      stream_arn = var.kinesis_stream_arn
    }
  }
}
