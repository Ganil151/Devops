# 08. CloudWatch Anomaly Detection
# Automatically identifying unusual behavior in metrics without setting manual thresholds.

resource "aws_cloudwatch_metric_alarm" "anomaly_alarm" {
  alarm_name          = "anomaly-detection-alarm"
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  evaluation_periods  = "2"
  threshold_metric_id = "ad1"

  metric_query {
    id          = "m1"
    return_data = true
    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = "600"
      stat        = "Sum"
    }
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    label       = "RequestCount (Expected)"
    return_data = true
  }
}
