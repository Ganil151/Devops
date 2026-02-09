# 03. CloudWatch Metric Filter
# extracting a numeric metric from unstructured log data (e.g., counting "ERROR" occurrences).

resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "MyAppErrorCount"
  pattern        = "\"ERROR\""
  log_group_name = aws_cloudwatch_log_group.standard.name

  metric_transformation {
    name      = "ErrorCount"
    namespace = "MyAppMetrics"
    value     = "1"
  }
}
