# 07. Table with Streams Enabled
# Captures item-level changes (Insert, Update, Delete) for downstream processing.

resource "aws_dynamodb_table" "with_streams" {
  name             = "ChangeFeedTable"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "Id"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "Id"
    type = "S"
  }
}
