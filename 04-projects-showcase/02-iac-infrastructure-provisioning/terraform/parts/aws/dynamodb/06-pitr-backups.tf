# 06. Table with Continuous Backups (PITR)
# protection against accidental deletes with 35-day point-in-time recovery.

resource "aws_dynamodb_table" "with_backups" {
  name         = "CoreFinancialData"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "TransactionId"

  attribute {
    name = "TransactionId"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }
}
