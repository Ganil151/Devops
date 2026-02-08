# 02. CloudWatch Metric Alarm (CPU)
# Alerting on high CPU utilization for an EC2 instance.

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "ec2-high-cpu-usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    InstanceId = var.instance_id
  }
}
