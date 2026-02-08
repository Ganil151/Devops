# 17. Table with Import from S3 Configuration
# prepares a table to import data from S3 (CSV, JSON, or Ion format).

# (Currently, the 'import_table' resource is not available in basic aws provider)
# (But you can define the table and use the console or CLI for the import)

resource "aws_dynamodb_table" "import_target" {
  name         = "ImportedData"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ImportKey"

  attribute {
    name = "ImportKey"
    type = "S"
  }
}
