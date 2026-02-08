# 01. Basic DynamoDB Table (On-Demand)
# Cost-effective "Pay-per-request" scaling for unpredictable workloads.

resource "aws_dynamodb_table" "basic_ondemand" {
  name         = "UserEvents"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "UserId"
  range_key    = "Timestamp"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "N"
  }

  tags = {
    Environment = "Dev"
  }
}
