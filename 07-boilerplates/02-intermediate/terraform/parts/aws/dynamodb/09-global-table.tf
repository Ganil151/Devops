# 09. Global Table (Multi-Region Replication)
# Replicating data across multiple AWS regions for low-latency global access.

resource "aws_dynamodb_table" "global_table" {
  name             = "GlobalInventory"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "SKU"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "SKU"
    type = "S"
  }

  replica {
    region_name = "us-east-1"
  }

  replica {
    region_name = "eu-west-1"
  }
}
# (Note: Requires a provider configured for each region)
