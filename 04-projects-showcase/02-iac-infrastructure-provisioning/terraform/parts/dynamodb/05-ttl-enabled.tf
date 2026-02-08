# 05. Table with TTL (Time To Live)
# Automatically expires and deletes items after a specific timestamp.

resource "aws_dynamodb_table" "with_ttl" {
  name         = "SessionData"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "SessionId"

  attribute {
    name = "SessionId"
    type = "S"
  }

  ttl {
    attribute_name = "ExpiresAt"
    enabled        = true
  }
}
