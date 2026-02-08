# 19. CloudWatch Metric Data Query (Math)
# creating a derivative metric using math expressions (e.g., Error Rate = Errors / Requests).

resource "aws_cloudwatch_metric_alarm" "error_rate_alarm" {
  alarm_name          = "high-error-rate-percent"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  threshold           = "5" # 5% Error Rate

  metric_query {
    id          = "e1"
    expression  = "m2/m1*100"
    label       = "Error Rate"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "Requests"
      namespace   = "AWS/ApplicationELB"
      period      = "300"
      stat        = "Sum"
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "HTTPCode_Target_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = "300"
      stat        = "Sum"
    }
  }
}
