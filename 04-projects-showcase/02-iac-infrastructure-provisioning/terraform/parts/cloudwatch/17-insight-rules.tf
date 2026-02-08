# 17. CloudWatch Insight Rule
# monitoring high-cardinality contributors to logs (e.g., top IP addresses hitting the LB).

resource "aws_cloudwatch_insight_rule" "top_ips" {
  rule_name = "TopIPsByRequestCount"
  rule_state = "ENABLED"
  
  rule_definition = jsonencode({
    Schema = { Name = "CloudWatchLogRule", Version = 1 }
    LogGroups = [aws_cloudwatch_log_group.standard.name]
    LogFormat = "CLF"
    Contribution = {
      Keys = ["$client_ip"]
      ValueOf = "$request_count"
      Filters = []
    }
  })
}
