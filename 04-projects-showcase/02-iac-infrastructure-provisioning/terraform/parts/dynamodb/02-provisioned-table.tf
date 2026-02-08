# 02. Provisioned DynamoDB Table
# Fixed capacity for predictable workloads where budget control is priority.

resource "aws_dynamodb_table" "provisioned" {
  name           = "ApplicationSettings"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "SettingKey"

  attribute {
    name = "SettingKey"
    type = "S"
  }
}
