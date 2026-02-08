# 17. S3 Bucket with IP Whitelist Policy
# Access is restricted to a specific set of CIDR ranges.

resource "aws_s3_bucket" "restricted_ip" {
  bucket = "ip-restricted-storage-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_policy" "allow_specific_ip" {
  bucket = aws_s3_bucket.restricted_ip.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "IPWhitelistPolicy"
    Statement = [
      {
        Sid       = "IPAllow"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.restricted_ip.arn,
          "${aws_s3_bucket.restricted_ip.arn}/*",
        ]
        Condition = {
          NotIpAddress = {
            "aws:SourceIp" = ["203.0.113.0/24"]
          }
        }
      },
    ]
  })
}
