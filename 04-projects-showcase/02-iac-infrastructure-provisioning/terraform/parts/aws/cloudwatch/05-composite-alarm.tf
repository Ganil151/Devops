# 05. CloudWatch Composite Alarm
# combining multiple alarms into one (e.g., High CPU AND High Memory).

resource "aws_cloudwatch_composite_alarm" "high_load" {
  alarm_name        = "HighLoadComposite"
  alarm_description = "Composite alarm for high CPU and memory"

  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.cpu_high.alarm_name}) AND ALARM(${var.memory_alarm_name})"

  alarm_actions = [var.sns_topic_arn]
}
