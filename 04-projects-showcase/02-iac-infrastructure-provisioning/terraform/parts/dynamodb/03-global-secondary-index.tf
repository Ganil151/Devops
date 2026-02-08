# 03. Table with Global Secondary Index (GSI)
# enabling queries on non-key attributes across the entire table.

resource "aws_dynamodb_table" "with_gsi" {
  name         = "OrdersTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "OrderId"

  attribute {
    name = "OrderId"
    type = "S"
  }

  attribute {
    name = "CustomerId"
    type = "S"
  }

  global_secondary_index {
    name               = "CustomerIndex"
    hash_key           = "CustomerId"
    projection_type    = "ALL"
  }
}
