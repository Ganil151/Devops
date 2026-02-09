# 16. MFA Delete S3 Bucket
# Requires MFA authentication to permanently delete an object version or change versioning.

resource "aws_s3_bucket" "mfa_delete" {
  bucket = "highly-secure-mfa-delete-${random_id.bucket_id.hex}"
}

# Note: MFA Delete can only be enabled via AWS CLI or API after MFA is configured.
# Terraform can manage the configuration if the credentials used have MFA.
resource "aws_s3_bucket_versioning" "mfa_delete" {
  bucket = aws_s3_bucket.mfa_delete.id
  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Disabled" # Change to Enabled with proper MFA setup
  }
}
