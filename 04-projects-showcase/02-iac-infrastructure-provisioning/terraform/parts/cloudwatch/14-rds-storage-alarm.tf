# 14. CloudWatch Alarm for RDS Free Storage
# Critical alert for database disk space to prevent data corruption/outages.

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "rds-low-storage-space"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "5000000000" # 5GB

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}
