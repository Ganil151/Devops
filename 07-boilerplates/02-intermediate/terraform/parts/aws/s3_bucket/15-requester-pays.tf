# 15. Requester Pays S3 Bucket
# The requester (not the owner) pays for data transfer and request costs.

resource "aws_s3_bucket" "requester_pays" {
  bucket = "data-lake-requester-pays-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_request_payment_configuration" "requester_pays" {
  bucket = aws_s3_bucket.requester_pays.id
  payer  = "Requester"
}
