# 15. Multi-Tenant Data Table (Example)
# using a composite key (TenantID + ItemID) to isolate data by tenant.

resource "aws_dynamodb_table" "multitenant" {
  name         = "SaaSData"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "TenantID"
  range_key    = "ItemID"

  attribute {
    name = "TenantID"
    type = "S"
  }

  attribute {
    name = "ItemID"
    type = "S"
  }
}
