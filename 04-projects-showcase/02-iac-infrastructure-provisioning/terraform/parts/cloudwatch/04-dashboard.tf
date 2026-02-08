# 04. CloudWatch Dashboard
# creating a visual dashboard with CPU and Memory widgets.

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "Infrastructure-Overview"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", var.instance_id]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "EC2 CPU Utilization"
        }
      }
    ]
  })
}
