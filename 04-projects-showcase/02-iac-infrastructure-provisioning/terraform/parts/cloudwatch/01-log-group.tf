# 01. CloudWatch Log Group
# Standard log group with retention policy.

resource "aws_cloudwatch_log_group" "standard" {
  name              = "/aws/lambda/my-function"
  retention_in_days = 30
}
