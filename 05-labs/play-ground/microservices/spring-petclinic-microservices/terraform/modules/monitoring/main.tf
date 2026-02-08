resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/eks/${var.environment}-petclinic/app"
  retention_in_days = 7
}
