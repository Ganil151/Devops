# 13. CloudWatch Alarm for S3 Bucket Size
# Monitoring storage growth over time.

resource "aws_cloudwatch_metric_alarm" "bucket_size" {
  alarm_name          = "s3-bucket-size-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = "86400" # daily check
  statistic           = "Average"
  threshold           = "1000000000" # 1GB
  
  dimensions = {
    BucketName = var.bucket_name
    StorageType = "StandardStorage"
  }
}
