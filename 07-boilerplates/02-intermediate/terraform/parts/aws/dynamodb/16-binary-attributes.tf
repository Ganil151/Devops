# 16. Table with Binary Attributes
# storing small binary blobs directly in the table.

resource "aws_dynamodb_table" "binary_store" {
  name         = "BinaryBlobTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "BlobId"

  attribute {
    name = "BlobId"
    type = "S"
  }

  # Attribute 'Data' would be type "B" (Binary) but doesn't need to be in the HCL schema
  # unless it's a key attribute.
}
