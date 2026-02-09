# 14. Table for Session Management (Example)
# schema optimized for storing web sessions with expiration.

resource "aws_dynamodb_table" "sessions" {
  name         = "UserSessions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "SessionToken"

  attribute {
    name = "SessionToken"
    type = "S"
  }

  ttl {
    attribute_name = "ExpirationTime"
    enabled        = true
  }

  tags = {
    Usage = "SessionStore"
  }
}
