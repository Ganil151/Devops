resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/eks/${var.environment}-petclinic/app"
  retention_in_days = 7
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "${var.environment}-eks-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EKS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EKS cluster cpu utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ClusterName = var.cluster_name
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.environment}-petclinic-metrics"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EKS", "CPUUtilization", "ClusterName", var.cluster_name]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "EKS CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_identifier]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "RDS CPU Utilization"
        }
      }
    ]
  })
}
