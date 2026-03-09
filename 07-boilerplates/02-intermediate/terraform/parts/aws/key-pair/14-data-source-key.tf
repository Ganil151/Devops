# 14. Reference Existing Key
# Use data source to reference existing key pair.

data "aws_key_pair" "existing" {
  key_name = "my-existing-key"
}

output "existing_key_fingerprint" {
  value = data.aws_key_pair.existing.fingerprint
}

output "existing_key_id" {
  value = data.aws_key_pair.existing.id
}
