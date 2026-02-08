# 18. Table with Export to S3 enabled
# allows full table exports to an S3 bucket in DynamoDB JSON or Amazon Ion format.

resource "aws_dynamodb_table" "export_enabled" {
  name         = "ExportableTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "DataId"

  attribute {
    name = "DataId"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true # PITR must be enabled for S3 Export
  }
}
