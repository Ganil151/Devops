# 11. S3 Bucket with Inventory
# Generates a flat file list of objects and their metadata daily or weekly.

resource "aws_s3_bucket" "inventory_source" {
  bucket = "inventory-source-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket" "inventory_dest" {
  bucket = "inventory-destination-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_inventory" "daily_report" {
  bucket = aws_s3_bucket.inventory_source.id
  name   = "DailyInventory"

  included_object_versions = "All"

  schedule {
    frequency = "Daily"
  }

  destination {
    s3_bucket {
      format     = "ORC"
      bucket_arn = aws_s3_bucket.inventory_dest.arn
      prefix     = "inventory-reports"
    }
  }
}
