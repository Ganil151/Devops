# 08. Table with Server-Side Encryption (KMS)
# encrypting data-at-rest using a Customer Managed Key (CMK).

resource "aws_dynamodb_table" "encrypted_table" {
  name         = "EncryptedUserPII"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Email"

  attribute {
    name = "Email"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }
}
