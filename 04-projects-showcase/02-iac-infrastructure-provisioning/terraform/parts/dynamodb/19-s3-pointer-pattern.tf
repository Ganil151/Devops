# 19. Large Item Support (S3 Pointer) Configuration
# handling items larger than 400KB by storing the payload in S3.

resource "aws_dynamodb_table" "s3_pointers" {
  name         = "LargeObjectMetadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ObjectId"

  attribute {
    name = "ObjectId"
    type = "S"
  }
}

resource "aws_s3_bucket" "payload_store" {
  bucket = "dynamodb-payloads-${random_id.bucket_id.hex}"
}
