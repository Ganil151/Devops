# 20. Minimalist CloudWatch Alarm
# The absolute barebones alert definition.

resource "aws_cloudwatch_metric_alarm" "minimal" {
  alarm_name          = "baseline-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "CustomNamespace"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
}
