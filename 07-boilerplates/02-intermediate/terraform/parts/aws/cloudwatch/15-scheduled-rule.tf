# 15. CloudWatch EvendBridge Scheduled Rule
# The underlying mechanism for "Cron-Lambda" or "Scheduled Task" patterns.

resource "aws_cloudwatch_event_rule" "scheduled_trigger" {
  name        = "recurring-maintenance-trigger"
  description = "Triggers every Sunday at 4 AM"
  schedule_expression = "cron(0 4 ? * SUN *)"
}
