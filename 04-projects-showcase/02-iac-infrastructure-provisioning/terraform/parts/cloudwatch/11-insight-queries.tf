# 11. CloudWatch Insight Query
# Saved queries for analyzing log data at scale.

resource "aws_cloudwatch_query_definition" "http_5xx_errors" {
  name = "LogInsights/HTTP-5XX-Errors"

  log_group_names = [
    aws_cloudwatch_log_group.standard.name
  ]

  query_string = <<EOF
fields @timestamp, @message
| filter @message like /500/
| sort @timestamp desc
| limit 20
EOF
}
