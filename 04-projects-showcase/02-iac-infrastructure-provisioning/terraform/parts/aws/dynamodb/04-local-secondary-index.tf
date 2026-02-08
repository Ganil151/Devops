# 04. Table with Local Secondary Index (LSI)
# enabling queries on the same partition key but with a different sort key.

resource "aws_dynamodb_table" "with_lsi" {
  name         = "ProductCatalog"
  billing_mode = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "Category"
  range_key      = "ProductId"

  attribute {
    name = "Category"
    type = "S"
  }

  attribute {
    name = "ProductId"
    type = "S"
  }

  attribute {
    name = "Price"
    type = "N"
  }

  local_secondary_index {
    name            = "PriceIndex"
    range_key       = "Price"
    projection_type = "INCLUDE"
    non_key_attributes = ["ProductName"]
  }
}
