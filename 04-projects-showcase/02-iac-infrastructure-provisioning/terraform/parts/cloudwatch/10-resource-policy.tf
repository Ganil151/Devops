# 10. CloudWatch Log Resource Policy
# Allowing other services (like Route53 or VPC Flow Logs) to write to the log group.

resource "aws_cloudwatch_log_resource_policy" "example" {
  policy_name = "allow-vpc-flow-logs"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Principal = { Service = "delivery.logs.amazonaws.com" }
        Resource = "${aws_cloudwatch_log_group.standard.arn}:*"
      },
    ]
  })
}
