# 20. Minimalist DynamoDB Table
# The absolute barebones table definition.

resource "aws_dynamodb_table" "minimal" {
  name         = "POC-Table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Id"

  attribute {
    name = "Id"
    type = "S"
  }
}
