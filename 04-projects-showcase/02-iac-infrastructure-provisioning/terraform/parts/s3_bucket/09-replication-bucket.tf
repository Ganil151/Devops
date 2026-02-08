# 09. S3 Bucket with Replication (CRR)
# Replicates data across different AWS regions.

resource "aws_s3_bucket" "source" {
  bucket = "source-replication-bucket-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_versioning" "source" {
  bucket = aws_s3_bucket.source.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "destination" {
  bucket = "dest-replication-bucket-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_versioning" "destination" {
  bucket = aws_s3_bucket.destination.id
  versioning_configuration {
    status = "Enabled"
  }
}

# (IAM Role for replication would be required in a real scenario)
resource "aws_s3_bucket_replication_configuration" "replication" {
  depends_on = [aws_s3_bucket_versioning.source]

  role   = "arn:aws:iam::123456789012:role/replication-role"
  bucket = aws_s3_bucket.source.id

  rule {
    id     = "replicate-all"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = "STANDARD"
    }
  }
}
